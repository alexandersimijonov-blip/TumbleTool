#!/bin/bash

# =================================================================
# 1. DEL: PREVERJANJE ODVISNOSTI (TumbleTool setup)
# =================================================================

if [ -f /usr/bin/zypper ]; then
    if ! rpm -q python3-tk >/dev/null 2>&1; then
        echo "Pripravljam TumbleTool grafično okolje..."
        sudo zypper install -y python3-tk tcl tk
    fi
fi

# =================================================================
# 2. DEL: TumbleTool PYTHON GRAFIČNI VMESNIK
# =================================================================

python3 - << 'EOF'
import os
import tkinter as tk
from tkinter import messagebox
import subprocess
import shutil
import platform

LANGS = {
    "SLO": {
        "title": "TumbleTool v2.2",
        "header": "🚀 TumbleTool Linux 2026",
        "update": "🔄 POSODOBI SISTEM",
        "clean": "🧹 OČISTI SISTEM",
        "vs": "💻 NAMESTI VSCODIUM",
        "info": "ℹ️ INFO SISTEM",
        "done": "KONČANO! Pritisni ENTER",
        "suse": "Namesti za: openSUSE",
        "ubuntu": "Namesti za: Debian/Ubuntu",
        "fedora": "Namesti za: Fedora",
        "arch": "Namesti za: Arch Linux"
    },
    "ENG": {
        "title": "TumbleTool v2.2",
        "header": "🚀 TumbleTool Linux 2026",
        "update": "🔄 UPDATE SYSTEM",
        "clean": "🧹 CLEAN SYSTEM",
        "vs": "💻 INSTALL VSCODIUM",
        "info": "ℹ️ SYSTEM INFO",
        "done": "DONE! Press ENTER",
        "suse": "Install for: openSUSE",
        "ubuntu": "Install for: Debian/Ubuntu",
        "fedora": "Install for: Fedora",
        "arch": "Install for: Arch Linux"
    },
    "GER": {
        "title": "TumbleTool v2.2",
        "header": "🚀 TumbleTool Linux 2026",
        "update": "🔄 AKTUALISIEREN",
        "clean": "🧹 REINIGEN",
        "vs": "💻 VSCODIUM INSTALL",
        "info": "ℹ️ SYSTEM INFO",
        "done": "FERTIG! ENTER DRÜCKEN",
        "suse": "Für openSUSE",
        "ubuntu": "Für Debian/Ubuntu",
        "fedora": "Für Fedora",
        "arch": "Für Arch Linux"
    }
}

class App:
    def __init__(self, root):
        self.root = root
        self.current_lang = "SLO"
        self.root.configure(bg='#1a1b26')
        self.setup_ui()

    def setup_ui(self):
        for widget in self.root.winfo_children():
            widget.destroy()

        l = LANGS[self.current_lang]
        self.root.title(l["title"])
        # Nastavimo fiksno velikost, ki preverjeno deluje
        self.root.geometry("460x720")

        # JEZIKI (SLO, ENG, GER)
        f_lang = tk.Frame(self.root, bg='#1a1b26')
        f_lang.pack(pady=15)
        for lang_code in ["SLO", "ENG", "GER"]:
            tk.Button(f_lang, text=lang_code, command=lambda c=lang_code: self.change_lang(c),
                      bg="#414868", fg="white", font=("Arial", 9, "bold"),
                      bd=0, width=8, cursor="hand2").pack(side="left", padx=5)

        # INFO GUMB (Na vrhu za boljšo vidljivost)
        tk.Button(self.root, text=l["info"], width=38, height=2, bg="#bb9af7", fg="black",
                  font=("Arial", 10, "bold"), bd=0, cursor="hand2", command=self.show_info).pack(pady=10)

        tk.Label(self.root, text=l["header"], font=("Arial", 16, "bold"),
                 fg="#7aa2f7", bg='#1a1b26').pack(pady=10)

        # DISTRIBUCIJE
        for sys_id, key in [("Fedora", "fedora"), ("Ubuntu", "ubuntu"), ("Arch", "arch"), ("openSUSE", "suse")]:
            tk.Button(self.root, text=l[key], width=42, height=2, bg="#24283b", fg="#cfc9c2",
                      bd=0, font=("Arial", 10), cursor="hand2",
                      command=lambda s=sys_id: self.run_install(s)).pack(pady=4)

        tk.Frame(self.root, height=2, bg="#414868").pack(fill="x", padx=40, pady=15)

        # SISTEMSKA ORODJA
        tk.Button(self.root, text=l["update"], width=42, height=2, bg="#2ac3de", fg="black",
                  font=("Arial", 10, "bold"), bd=0, cursor="hand2", command=self.update_all).pack(pady=5)

        tk.Button(self.root, text=l["clean"], width=42, height=2, bg="#f7768e", fg="white",
                  font=("Arial", 10), bd=0, cursor="hand2", command=self.clean_system).pack(pady=5)

        tk.Button(self.root, text=l["vs"], width=42, height=2, bg="#10b981", fg="white",
                  font=("Arial", 10, "bold"), bd=0, cursor="hand2", command=self.install_vscodium).pack(pady=5)

    def change_lang(self, lang_code):
        self.current_lang = lang_code
        self.setup_ui()

    def show_info(self):
        uname = platform.uname()
        try:
            uptime = subprocess.check_output("uptime -p", shell=True).decode().strip()
        except:
            uptime = "N/A"
        info_msg = (
            f"PROJEKT: TumbleTool 2026\n"
            f"SISTEM: {platform.system()} {platform.release()}\n"
            f"KERNEL: {uname.release}\n"
            f"UPTIME: {uptime}\n"
            f"UPORABNIK: {os.getlogin()}"
        )
        messagebox.showinfo(LANGS[self.current_lang]["info"], info_msg)

    def get_terminal_command(self, full_cmd):
        d = LANGS[self.current_lang]["done"]
        if shutil.which("konsole"):
            return f"konsole --noclose -e bash -c \"{full_cmd}; echo; echo '{d}'; read\""
        elif shutil.which("gnome-terminal"):
            return f"gnome-terminal -- bash -c \"{full_cmd}; echo; echo '{d}'; read\""
        else:
            return f"xterm -hold -e bash -c \"{full_cmd}; echo; echo '{d}'\""

    def run_install(self, s):
        p = "python3 git curl vlc aria2 mpv flatpak"
        if "Fedora" in s: cmd = f"sudo dnf install -y {p} python3-tkinter"
        elif "Ubuntu" in s: cmd = f"sudo apt update && sudo apt install -y {p} python3-tk"
        elif "Arch" in s: cmd = f"sudo pacman -Sy --noconfirm {p} tk"
        else: cmd = f"sudo zypper refresh && sudo zypper install -y {p} python3-tk"
        subprocess.Popen(self.get_terminal_command(cmd), shell=True)

    def update_all(self):
        cmd = "if [ -f /usr/bin/zypper ]; then sudo zypper ref && sudo zypper dup -y; elif [ -f /usr/bin/apt ]; then sudo apt update && sudo apt upgrade -y; elif [ -f /usr/bin/dnf ]; then sudo dnf upgrade --refresh -y; elif [ -f /usr/bin/pacman ]; then sudo pacman -Syu --noconfirm; fi; flatpak update -y"
        subprocess.Popen(self.get_terminal_command(cmd), shell=True)

    def clean_system(self):
        cmd = "if [ -f /usr/bin/zypper ]; then sudo zypper clean -a; elif [ -f /usr/bin/apt ]; then sudo apt autoremove -y; elif [ -f /usr/bin/dnf ]; then sudo dnf autoremove -y; elif [ -f /usr/bin/pacman ]; then sudo pacman -Sc --noconfirm; fi; flatpak uninstall --unused -y"
        subprocess.Popen(self.get_terminal_command(cmd), shell=True)

    def install_vscodium(self):
        cmd = "sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && flatpak install -y flathub com.vscodium.codium"
        subprocess.Popen(self.get_terminal_command(cmd), shell=True)

if __name__ == "__main__":
    root = tk.Tk()
    w, h = 460, 720
    # Centriranje okna na zaslonu
    root.geometry(f"{w}x{h}+{(root.winfo_screenwidth()//2)-(w//2)}+{(root.winfo_screenheight()//2)-(h//2)}")
    app = App(root)
    root.mainloop()
EOF
