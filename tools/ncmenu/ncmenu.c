#include <ctype.h>
#include <ncurses.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char *label;
    char *value;
} Item;

static char *xstrdup(const char *s) {
    size_t n = strlen(s) + 1;
    char *p = (char *)malloc(n);
    if (!p) return NULL;
    memcpy(p, s, n);
    return p;
}

static void trim(char *s) {
    char *p = s;
    while (*p && isspace((unsigned char)*p)) p++;
    if (p != s) memmove(s, p, strlen(p) + 1);
    size_t len = strlen(s);
    while (len > 0 && isspace((unsigned char)s[len - 1])) {
        s[len - 1] = '\0';
        len--;
    }
}

static int load_items(Item **out_items) {
    char *line = NULL;
    size_t cap = 0;
    ssize_t nread;
    size_t count = 0;
    size_t alloc_count = 16;
    Item *items = (Item *)calloc(alloc_count, sizeof(Item));
    if (!items) return -1;

    while ((nread = getline(&line, &cap, stdin)) != -1) {
        if (nread <= 1) continue;
        if (line[nread - 1] == '\n') line[nread - 1] = '\0';
        trim(line);
        if (line[0] == '\0' || line[0] == '#') continue;

        char *sep = strchr(line, '|');
        if (!sep) continue;
        *sep = '\0';
        char *label = line;
        char *value = sep + 1;
        trim(label);
        trim(value);
        if (label[0] == '\0' || value[0] == '\0') continue;

        if (count == alloc_count) {
            alloc_count *= 2;
            Item *tmp = (Item *)realloc(items, alloc_count * sizeof(Item));
            if (!tmp) {
                free(line);
                free(items);
                return -1;
            }
            items = tmp;
        }
        items[count].label = xstrdup(label);
        items[count].value = xstrdup(value);
        if (!items[count].label || !items[count].value) {
            free(line);
            for (size_t i = 0; i <= count; i++) {
                free(items[i].label);
                free(items[i].value);
            }
            free(items);
            return -1;
        }
        count++;
    }

    free(line);
    *out_items = items;
    return (int)count;
}

static void free_items(Item *items, int n) {
    if (!items) return;
    for (int i = 0; i < n; i++) {
        free(items[i].label);
        free(items[i].value);
    }
    free(items);
}

int main(int argc, char **argv) {
    const char *title = "Selection";
    for (int i = 1; i < argc; i++) {
        if (strcmp(argv[i], "--title") == 0 && i + 1 < argc) {
            title = argv[++i];
        }
    }

    Item *items = NULL;
    int count = load_items(&items);
    if (count <= 0) {
        free_items(items, count > 0 ? count : 0);
        return 1;
    }

    initscr();
    cbreak();
    noecho();
    keypad(stdscr, TRUE);
    curs_set(0);

    int selected = 0;
    int offset = 0;
    int ch;

    while (1) {
        int rows, cols;
        getmaxyx(stdscr, rows, cols);
        int list_height = rows - 4;
        if (list_height < 3) list_height = 3;

        if (selected < offset) offset = selected;
        if (selected >= offset + list_height) offset = selected - list_height + 1;

        erase();
        mvprintw(0, 0, "%s", title);
        mvhline(1, 0, ACS_HLINE, cols);

        for (int i = 0; i < list_height; i++) {
            int idx = offset + i;
            if (idx >= count) break;
            if (idx == selected) attron(A_REVERSE);
            mvprintw(2 + i, 0, " %s", items[idx].label);
            if (idx == selected) attroff(A_REVERSE);
        }

        mvhline(rows - 2, 0, ACS_HLINE, cols);
        mvprintw(rows - 1, 0, "Fleches: naviguer | Entree: valider | q: quitter");
        refresh();

        ch = getch();
        if (ch == KEY_UP || ch == 'k') {
            if (selected > 0) selected--;
        } else if (ch == KEY_DOWN || ch == 'j') {
            if (selected < count - 1) selected++;
        } else if (ch == 10 || ch == KEY_ENTER || ch == '\r') {
            endwin();
            printf("%s\n", items[selected].value);
            free_items(items, count);
            return 0;
        } else if (ch == 'q' || ch == 27) {
            endwin();
            free_items(items, count);
            return 1;
        }
    }
}

