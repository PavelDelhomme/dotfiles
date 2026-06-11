package main

import (
	"bufio"
	"errors"
	"flag"
	"fmt"
	"os"
	"strings"
	"syscall"
	"unsafe"
)

type item struct {
	label string
	value string
}

var screen = os.Stdout

func trim(s string) string {
	return strings.TrimSpace(s)
}

func loadItems() ([]item, error) {
	scanner := bufio.NewScanner(os.Stdin)
	items := make([]item, 0, 16)
	for scanner.Scan() {
		line := trim(scanner.Text())
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		parts := strings.SplitN(line, "|", 2)
		if len(parts) != 2 {
			continue
		}
		label := trim(parts[0])
		value := trim(parts[1])
		if label == "" || value == "" {
			continue
		}
		items = append(items, item{label: label, value: value})
	}
	if err := scanner.Err(); err != nil {
		return nil, err
	}
	if len(items) == 0 {
		return nil, errors.New("no items")
	}
	return items, nil
}

type termState struct {
	termios syscall.Termios
	ok      bool
}

func setRawMode(fd int) (termState, error) {
	var old syscall.Termios
	if _, _, errno := syscall.Syscall6(syscall.SYS_IOCTL, uintptr(fd), uintptr(syscall.TCGETS), uintptr(unsafe.Pointer(&old)), 0, 0, 0); errno != 0 {
		return termState{}, errno
	}
	raw := old
	raw.Iflag &^= syscall.IGNBRK | syscall.BRKINT | syscall.PARMRK | syscall.ISTRIP | syscall.INLCR | syscall.IGNCR | syscall.ICRNL | syscall.IXON
	raw.Oflag &^= syscall.OPOST
	raw.Lflag &^= syscall.ECHO | syscall.ECHONL | syscall.ICANON | syscall.ISIG | syscall.IEXTEN
	raw.Cflag &^= syscall.CSIZE | syscall.PARENB
	raw.Cflag |= syscall.CS8
	raw.Cc[syscall.VMIN] = 1
	raw.Cc[syscall.VTIME] = 0
	if _, _, errno := syscall.Syscall6(syscall.SYS_IOCTL, uintptr(fd), uintptr(syscall.TCSETS), uintptr(unsafe.Pointer(&raw)), 0, 0, 0); errno != 0 {
		return termState{}, errno
	}
	return termState{termios: old, ok: true}, nil
}

func restoreMode(fd int, st termState) {
	if !st.ok {
		return
	}
	_, _, _ = syscall.Syscall6(syscall.SYS_IOCTL, uintptr(fd), uintptr(syscall.TCSETS), uintptr(unsafe.Pointer(&st.termios)), 0, 0, 0)
}

func terminalSize(fd int) (rows, cols int) {
	type winsize struct {
		row uint16
		col uint16
		x   uint16
		y   uint16
	}
	ws := winsize{}
	if _, _, errno := syscall.Syscall6(syscall.SYS_IOCTL, uintptr(fd), uintptr(syscall.TIOCGWINSZ), uintptr(unsafe.Pointer(&ws)), 0, 0, 0); errno != 0 {
		return 24, 80
	}
	if ws.row == 0 || ws.col == 0 {
		return 24, 80
	}
	return int(ws.row), int(ws.col)
}

func clearScreen() {
	fmt.Fprint(screen, "\033[H\033[2J")
}

func draw(title string, items []item, selected, offset int) {
	rows, cols := terminalSize(int(screen.Fd()))
	listHeight := rows - 4
	if listHeight < 3 {
		listHeight = 3
	}

	clearScreen()
	fmt.Fprintln(screen, title)
	fmt.Fprintln(screen, strings.Repeat("─", cols))
	for i := 0; i < listHeight; i++ {
		idx := offset + i
		if idx >= len(items) {
			break
		}
		if idx == selected {
			fmt.Fprintf(screen, "\033[7m %s  %s \033[0m\n", items[idx].value, items[idx].label)
		} else {
			fmt.Fprintf(screen, " %s  %s\n", items[idx].value, items[idx].label)
		}
	}
	for i := len(items) - offset; i < listHeight; i++ {
		if i >= 0 {
			fmt.Fprintln(screen)
		}
	}
	fmt.Fprintln(screen, strings.Repeat("─", cols))
	fmt.Fprintln(screen, "Flèches/j/k: naviguer | Entrée: valider | touche (0/q/1…): selection directe")
}

func readKey(fd int) (string, error) {
	buf := make([]byte, 3)
	n, err := syscall.Read(fd, buf[:1])
	if err != nil {
		return "", err
	}
	if n == 0 {
		return "", errors.New("eof")
	}
	b := buf[0]
	switch b {
	case 'q':
		return "quit", nil
	case 'k':
		return "up", nil
	case 'j':
		return "down", nil
	case '\r', '\n':
		return "enter", nil
	case 27:
		n2, _ := syscall.Read(fd, buf[1:2])
		if n2 == 0 {
			return "quit", nil
		}
		if buf[1] != '[' {
			return "", nil
		}
		n3, _ := syscall.Read(fd, buf[2:3])
		if n3 == 0 {
			return "", nil
		}
		switch buf[2] {
		case 'A':
			return "up", nil
		case 'B':
			return "down", nil
		default:
			return "", nil
		}
	default:
		if b >= 32 && b <= 126 {
			return string(b), nil
		}
		return "", nil
	}
}

func valueForKey(items []item, key string) (string, bool) {
	for _, it := range items {
		if strings.EqualFold(it.value, key) {
			return it.value, true
		}
	}
	return "", false
}

func quitValue(items []item) (string, bool) {
	if v, ok := valueForKey(items, "q"); ok {
		return v, true
	}
	if v, ok := valueForKey(items, "0"); ok {
		return v, true
	}
	return "", false
}

func main() {
	title := flag.String("title", "Selection", "menu title")
	flag.Parse()

	items, err := loadItems()
	if err != nil {
		os.Exit(1)
	}

	tty, err := os.OpenFile("/dev/tty", os.O_RDWR, 0)
	if err != nil {
		fmt.Println(items[0].value)
		return
	}
	defer tty.Close()
	screen = tty

	stdinFd := int(tty.Fd())
	stdoutFd := int(tty.Fd())
	if !isTTY(stdinFd) || !isTTY(stdoutFd) {
		fmt.Println(items[0].value)
		return
	}

	state, err := setRawMode(stdinFd)
	if err != nil {
		os.Exit(1)
	}
	defer restoreMode(stdinFd, state)
	defer fmt.Fprint(screen, "\033[0m\033[?25h")

	selected := 0
	offset := 0
	for {
		rows, _ := terminalSize(stdoutFd)
		listHeight := rows - 4
		if listHeight < 3 {
			listHeight = 3
		}
		if selected < offset {
			offset = selected
		}
		if selected >= offset+listHeight {
			offset = selected - listHeight + 1
		}

		draw(*title, items, selected, offset)
		key, err := readKey(stdinFd)
		if err != nil {
			os.Exit(1)
		}
		switch key {
		case "up":
			if selected > 0 {
				selected--
			}
		case "down":
			if selected < len(items)-1 {
				selected++
			}
		case "enter":
			clearScreen()
			fmt.Println(items[selected].value)
			return
		case "quit":
			clearScreen()
			if v, ok := quitValue(items); ok {
				fmt.Println(v)
				return
			}
			os.Exit(1)
		default:
			if v, ok := valueForKey(items, key); ok {
				clearScreen()
				fmt.Println(v)
				return
			}
		}
	}
}

func isTTY(fd int) bool {
	var termios syscall.Termios
	_, _, errno := syscall.Syscall6(syscall.SYS_IOCTL, uintptr(fd), uintptr(syscall.TCGETS), uintptr(unsafe.Pointer(&termios)), 0, 0, 0)
	return errno == 0
}
