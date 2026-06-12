#define _POSIX_C_SOURCE 200809L

#include <errno.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <termios.h>
#include <unistd.h>

#define DOTCLI_MAX_MENU_ITEMS 512
#define DOTCLI_MAX_LABEL 512
#define DOTCLI_MAX_KEY 128

static struct termios dotcli_saved_termios;
static int dotcli_termios_saved = 0;
static int dotcli_tty_input_fd = -1;

typedef struct {
    int fd;
    int own;
} DotcliInput;

static DotcliInput dotcli_resolve_input(void) {
    DotcliInput in = {STDIN_FILENO, 0};
    if (isatty(STDIN_FILENO)) {
        return in;
    }
    {
        int tty_fd = open("/dev/tty", O_RDWR);
        if (tty_fd >= 0 && isatty(tty_fd)) {
            in.fd = tty_fd;
            in.own = 1;
            return in;
        }
        if (tty_fd >= 0) {
            (void)close(tty_fd);
        }
    }
    in.fd = -1;
    return in;
}

static void dotcli_release_input(const DotcliInput *in) {
    if (in != NULL && in->own && in->fd >= 0) {
        (void)close(in->fd);
    }
}

static void dotcli_restore_tty(void) {
    if (dotcli_termios_saved && dotcli_tty_input_fd >= 0) {
        (void)tcsetattr(dotcli_tty_input_fd, TCSAFLUSH, &dotcli_saved_termios);
        dotcli_termios_saved = 0;
        dotcli_tty_input_fd = -1;
    }
}

static volatile sig_atomic_t dotcli_got_signal = 0;

static void dotcli_on_signal(int sig) {
    (void)sig;
    dotcli_got_signal = 1;
}

static void print_usage(void) {
    puts("dotcli - socle commun experimental");
    puts("");
    puts("Usage:");
    puts("  dotcli doctor");
    puts("  dotcli menu [--prompt TEXT] [--items-file PATH] [--query TERM] [--no-tui]");
    puts("              [--simulate-index N] [--dry-run]");
    puts("  dotcli render [--color COLOR]");
    puts("");
    puts("Variables:");
    puts("  DOTFILES_DOTCLI_MENU_NO_TUI=1  force le mode ligne (comme --no-tui)");
}

static int cmd_doctor(void) {
    const int tty_in = isatty(STDIN_FILENO) ? 1 : 0;
    const int tty_out = isatty(STDOUT_FILENO) ? 1 : 0;
    const char *term = getenv("TERM");
    printf("dotcli_doctor: ok\n");
    printf("stdin_tty=%d\n", tty_in);
    printf("stdout_tty=%d\n", tty_out);
    printf("term=%s\n", term ? term : "unknown");
    return 0;
}

typedef struct {
    char label[DOTCLI_MAX_LABEL];
    char key[DOTCLI_MAX_KEY];
} DotcliMenuItem;

static int parse_menu_items_stream(FILE *stream, DotcliMenuItem *items, int *count) {
    char line[4096];
    int idx = 0;

    while (fgets(line, sizeof(line), stream) != NULL) {
        char *sep = strchr(line, '|');
        char *label;
        char *key;
        char *nl;

        if (!sep) {
            continue;
        }
        if (idx >= DOTCLI_MAX_MENU_ITEMS) {
            break;
        }

        *sep = '\0';
        label = line;
        key = sep + 1;
        nl = strchr(key, '\n');
        if (nl) {
            *nl = '\0';
        }
        if (label[0] == '\0' || key[0] == '\0') {
            continue;
        }

        strncpy(items[idx].label, label, DOTCLI_MAX_LABEL - 1);
        items[idx].label[DOTCLI_MAX_LABEL - 1] = '\0';
        strncpy(items[idx].key, key, DOTCLI_MAX_KEY - 1);
        items[idx].key[DOTCLI_MAX_KEY - 1] = '\0';
        idx++;
    }

    *count = idx;
    return idx > 0 ? 0 : 1;
}

static int parse_menu_items(DotcliMenuItem *items, int *count) {
    return parse_menu_items_stream(stdin, items, count);
}

static int parse_menu_items_file(const char *path, DotcliMenuItem *items, int *count) {
    FILE *fp = fopen(path, "r");
    if (fp == NULL) {
        return 1;
    }
    {
        int rc = parse_menu_items_stream(fp, items, count);
        (void)fclose(fp);
        return rc;
    }
}

static int menu_emit_choice(const DotcliMenuItem *items, int count, int index) {
    if (index < 0 || index >= count) {
        return 1;
    }
    puts(items[index].key);
    return 0;
}

static int dotcli_terminal_rows(void) {
    struct winsize ws;
    const char *lines = getenv("LINES");
    char *endptr = NULL;
    long parsed = 0;

    if (ioctl(STDOUT_FILENO, TIOCGWINSZ, &ws) == 0 && ws.ws_row > 0) {
        return (int)ws.ws_row;
    }
    if (lines != NULL && lines[0] != '\0') {
        parsed = strtol(lines, &endptr, 10);
        if (endptr != lines && *endptr == '\0' && parsed > 0 && parsed < 1000) {
            return (int)parsed;
        }
    }
    return 24;
}

static int menu_visible_rows(int count) {
    int rows = dotcli_terminal_rows();
    int visible = rows - 7;
    if (visible < 5) {
        visible = 5;
    }
    if (visible > 20) {
        visible = 20;
    }
    if (visible > count) {
        visible = count;
    }
    return visible > 0 ? visible : 1;
}

static int menu_scroll_offset(int sel, int count, int visible, int current) {
    int max_offset = count - visible;
    if (max_offset < 0) {
        max_offset = 0;
    }
    if (current < 0) {
        current = 0;
    }
    if (current > max_offset) {
        current = max_offset;
    }
    if (sel < current) {
        current = sel;
    } else if (sel >= current + visible) {
        current = sel - visible + 1;
    }
    if (current < 0) {
        current = 0;
    }
    if (current > max_offset) {
        current = max_offset;
    }
    return current;
}

static int menu_run_line_mode(const char *prompt, DotcliMenuItem *items, int count, int input_fd) {
    FILE *input = NULL;
    int close_input = 0;

    printf("%s\n", prompt);
    for (int i = 0; i < count; i++) {
        printf("  %d) %s\n", i + 1, items[i].label);
    }
    printf("Choix [1-%d, Entrée=1, ou clé]: ", count);
    fflush(stdout);

    if (input_fd >= 0) {
        input = fdopen(dup(input_fd), "r");
        if (input != NULL) {
            close_input = 1;
        }
    }
    if (input == NULL) {
        input = stdin;
    }

    {
        char answer[256];
        if (fgets(answer, sizeof(answer), input) == NULL) {
            if (close_input) {
                (void)fclose(input);
            }
            return menu_emit_choice(items, count, 0);
        }

        {
            char *nl = strchr(answer, '\n');
            if (nl) {
                *nl = '\0';
            }
        }

        if (answer[0] == '\0') {
            if (close_input) {
                (void)fclose(input);
            }
            return menu_emit_choice(items, count, 0);
        }

        {
            char *endptr = NULL;
            long idx = strtol(answer, &endptr, 10);
            if (endptr != answer && *endptr == '\0' && idx >= 1 && idx <= count) {
                if (close_input) {
                    (void)fclose(input);
                }
                return menu_emit_choice(items, count, (int)idx - 1);
            }
        }

        for (int i = 0; i < count; i++) {
            if (strcmp(answer, items[i].key) == 0) {
                if (close_input) {
                    (void)fclose(input);
                }
                return menu_emit_choice(items, count, i);
            }
        }

        for (int i = 0; i < count; i++) {
            if (strstr(items[i].label, answer) || strstr(items[i].key, answer)) {
                if (close_input) {
                    (void)fclose(input);
                }
                return menu_emit_choice(items, count, i);
            }
        }
    }

    if (close_input) {
        (void)fclose(input);
    }
    return 1;
}

static void menu_draw(const char *prompt, const DotcliMenuItem *items, int count, int sel, int offset) {
    int visible = menu_visible_rows(count);
    int end = offset + visible;
    if (end > count) {
        end = count;
    }

    printf("\033[2J\033[H");
    printf("%s\n\n", prompt);
    for (int i = offset; i < end; i++) {
        if (i == sel) {
            printf("  \033[7m %2d) %s \033[0m\n", i + 1, items[i].label);
        } else {
            printf("    %2d) %s\n", i + 1, items[i].label);
        }
    }
    if (count > visible) {
        printf("\n\033[2mLignes %d-%d/%d · PgUp/PgDn ou h/l · g/G début/fin\033[0m\n",
               offset + 1, end, count);
    }
    printf("\033[2m↑/↓ ou j/k · Entrée valider · q = 1er choix\033[0m\n");
    fflush(stdout);
}

static int menu_read_escape_arrow(int input_fd, int *out_delta, int *out_page_delta) {
    unsigned char seq[3];
    ssize_t n;
    *out_delta = 0;
    *out_page_delta = 0;
    n = read(input_fd, &seq[0], 1);
    if (n != 1) {
        return -1;
    }
    if (seq[0] != '[') {
        return 1;
    }
    n = read(input_fd, &seq[1], 1);
    if (n != 1) {
        return -1;
    }
    if (seq[1] == 'A') {
        *out_delta = -1;
    } else if (seq[1] == 'B') {
        *out_delta = 1;
    } else if (seq[1] == '5' || seq[1] == '6') {
        n = read(input_fd, &seq[2], 1);
        if (n == 1 && seq[2] == '~') {
            *out_page_delta = seq[1] == '5' ? -1 : 1;
        }
    }
    return 0;
}

static int menu_run_tui(const char *prompt, DotcliMenuItem *items, int count, int input_fd) {
    struct termios raw;
    int sel = 0;
    int offset = 0;
    struct sigaction sa, old_int, old_quit;

    if (input_fd < 0 || !isatty(STDOUT_FILENO)) {
        return menu_run_line_mode(prompt, items, count, input_fd);
    }

    dotcli_tty_input_fd = input_fd;
    if (tcgetattr(input_fd, &dotcli_saved_termios) == -1) {
        dotcli_tty_input_fd = -1;
        return menu_run_line_mode(prompt, items, count, input_fd);
    }
    dotcli_termios_saved = 1;
    raw = dotcli_saved_termios;
    raw.c_lflag &= (tcflag_t)~(ECHO | ICANON);
    raw.c_cc[VMIN] = 1;
    raw.c_cc[VTIME] = 0;
    if (tcsetattr(input_fd, TCSAFLUSH, &raw) == -1) {
        dotcli_restore_tty();
        return menu_run_line_mode(prompt, items, count, input_fd);
    }

    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = dotcli_on_signal;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;
    (void)sigaction(SIGINT, &sa, &old_int);
    (void)sigaction(SIGQUIT, &sa, &old_quit);

    dotcli_got_signal = 0;
    offset = menu_scroll_offset(sel, count, menu_visible_rows(count), offset);
    menu_draw(prompt, items, count, sel, offset);

    while (!dotcli_got_signal) {
        unsigned char c;
        ssize_t         n = read(input_fd, &c, 1);
        if (n != 1) {
            if (errno == EINTR && dotcli_got_signal) {
                break;
            }
            if (errno == EINTR) {
                continue;
            }
            break;
        }

        if (c == '\n' || c == '\r') {
            dotcli_restore_tty();
            (void)sigaction(SIGINT, &old_int, NULL);
            (void)sigaction(SIGQUIT, &old_quit, NULL);
            return menu_emit_choice(items, count, sel);
        }

        if (c == 'q' || c == 'Q') {
            dotcli_restore_tty();
            (void)sigaction(SIGINT, &old_int, NULL);
            (void)sigaction(SIGQUIT, &old_quit, NULL);
            return menu_emit_choice(items, count, 0);
        }

        if (c == 0x1b) {
            int d = 0;
            int page_d = 0;
            if (menu_read_escape_arrow(input_fd, &d, &page_d) == 0) {
                if (page_d != 0) {
                    int visible = menu_visible_rows(count);
                    sel += page_d * visible;
                    if (sel < 0) {
                        sel = 0;
                    }
                    if (sel >= count) {
                        sel = count - 1;
                    }
                    offset = menu_scroll_offset(sel, count, visible, offset);
                    menu_draw(prompt, items, count, sel, offset);
                } else if (d != 0) {
                    sel = (sel + d + count) % count;
                    offset = menu_scroll_offset(sel, count, menu_visible_rows(count), offset);
                    menu_draw(prompt, items, count, sel, offset);
                }
            }
            continue;
        }

        if (c == 'j' || c == 'J') {
            sel = (sel + 1 + count) % count;
            offset = menu_scroll_offset(sel, count, menu_visible_rows(count), offset);
            menu_draw(prompt, items, count, sel, offset);
            continue;
        }
        if (c == 'k' || c == 'K') {
            sel = (sel - 1 + count) % count;
            offset = menu_scroll_offset(sel, count, menu_visible_rows(count), offset);
            menu_draw(prompt, items, count, sel, offset);
            continue;
        }
        if (c == 'l' || c == 'L' || c == ' ') {
            int visible = menu_visible_rows(count);
            sel += visible;
            if (sel >= count) {
                sel = count - 1;
            }
            offset = menu_scroll_offset(sel, count, visible, offset);
            menu_draw(prompt, items, count, sel, offset);
            continue;
        }
        if (c == 'h' || c == 'H') {
            int visible = menu_visible_rows(count);
            sel -= visible;
            if (sel < 0) {
                sel = 0;
            }
            offset = menu_scroll_offset(sel, count, visible, offset);
            menu_draw(prompt, items, count, sel, offset);
            continue;
        }
        if (c == 'g') {
            sel = 0;
            offset = 0;
            menu_draw(prompt, items, count, sel, offset);
            continue;
        }
        if (c == 'G') {
            sel = count - 1;
            offset = menu_scroll_offset(sel, count, menu_visible_rows(count), offset);
            menu_draw(prompt, items, count, sel, offset);
            continue;
        }

        if (c >= '1' && c <= '9') {
            int idx = (int)(c - '1');
            if (idx < count) {
                sel = idx;
                offset = menu_scroll_offset(sel, count, menu_visible_rows(count), offset);
                menu_draw(prompt, items, count, sel, offset);
            }
            continue;
        }
    }

    dotcli_restore_tty();
    (void)sigaction(SIGINT, &old_int, NULL);
    (void)sigaction(SIGQUIT, &old_quit, NULL);
    if (dotcli_got_signal) {
        return 130;
    }
    return menu_emit_choice(items, count, 0);
}

static int cmd_menu(int argc, char **argv) {
    const char *prompt = "choice";
    const char *items_file = NULL;
    const char *query = NULL;
    DotcliMenuItem items[DOTCLI_MAX_MENU_ITEMS];
    int count = 0;
    int no_tui = 0;
    int dry_run = 0;
    int simulate_index = 0;
    DotcliInput input = {STDIN_FILENO, 0};
    int can_interact = 0;
    int rc = 1;

    {
        const char *e = getenv("DOTFILES_DOTCLI_MENU_NO_TUI");
        if (e && e[0] == '1' && e[1] == '\0') {
            no_tui = 1;
        }
    }

    for (int i = 0; i < argc; i++) {
        if (strcmp(argv[i], "--prompt") == 0 && i + 1 < argc) {
            prompt = argv[i + 1];
            i++;
        } else if (strcmp(argv[i], "--items-file") == 0 && i + 1 < argc) {
            items_file = argv[i + 1];
            i++;
        } else if (strcmp(argv[i], "--query") == 0 && i + 1 < argc) {
            query = argv[i + 1];
            i++;
        } else if (strcmp(argv[i], "--no-tui") == 0) {
            no_tui = 1;
        } else if (strcmp(argv[i], "--dry-run") == 0) {
            dry_run = 1;
        } else if (strcmp(argv[i], "--simulate-index") == 0 && i + 1 < argc) {
            simulate_index = (int)strtol(argv[i + 1], NULL, 10);
            i++;
        }
    }

    if (items_file != NULL && items_file[0] != '\0') {
        if (parse_menu_items_file(items_file, items, &count) != 0) {
            return 1;
        }
    } else if (parse_menu_items(items, &count) != 0) {
        return 1;
    }

    if (simulate_index >= 1 && simulate_index <= count) {
        return menu_emit_choice(items, count, simulate_index - 1);
    }

    if (dry_run) {
        int idx = 0;
        fputs("dotcli menu: dry-run (aucun mode brut terminal)\n", stderr);
        for (int i = 0; i < count; i++) {
            fprintf(stderr, "  %s%2d) %-40s  [%s]%s\n", i == idx ? ">> " : "   ", i + 1,
                    items[i].label, items[i].key, i == idx ? " <<" : "");
        }
        fprintf(stderr, "(sortie stdout = cle de l'item surligne)\n");
        return menu_emit_choice(items, count, idx);
    }

    input = dotcli_resolve_input();
    can_interact = isatty(STDOUT_FILENO) && input.fd >= 0;

    if (!can_interact) {
        if (query && query[0] != '\0') {
            for (int i = 0; i < count; i++) {
                if (strstr(items[i].label, query) || strstr(items[i].key, query)) {
                    puts(items[i].key);
                    dotcli_release_input(&input);
                    return 0;
                }
            }
        }
        puts(items[0].key);
        dotcli_release_input(&input);
        return 0;
    }

    if (no_tui) {
        rc = menu_run_line_mode(prompt, items, count, input.fd);
    } else {
        rc = menu_run_tui(prompt, items, count, input.fd);
    }
    dotcli_release_input(&input);
    return rc;
}

static int cmd_render(int argc, char **argv) {
    const char *color = "none";
    char line[4096];

    for (int i = 0; i < argc; i++) {
        if (strcmp(argv[i], "--color") == 0 && i + 1 < argc) {
            color = argv[i + 1];
            i++;
        }
    }

    while (fgets(line, sizeof(line), stdin) != NULL) {
        if (strcmp(color, "green") == 0) {
            fputs("\033[0;32m", stdout);
            fputs(line, stdout);
            fputs("\033[0m", stdout);
        } else if (strcmp(color, "yellow") == 0) {
            fputs("\033[1;33m", stdout);
            fputs(line, stdout);
            fputs("\033[0m", stdout);
        } else {
            fputs(line, stdout);
        }
    }
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        print_usage();
        return 1;
    }

    if (strcmp(argv[1], "doctor") == 0) {
        return cmd_doctor();
    }
    if (strcmp(argv[1], "menu") == 0) {
        int r = cmd_menu(argc - 2, argv + 2);
        dotcli_restore_tty();
        return r == 130 ? 130 : r;
    }
    if (strcmp(argv[1], "render") == 0) {
        return cmd_render(argc - 2, argv + 2);
    }

    print_usage();
    return 1;
}
