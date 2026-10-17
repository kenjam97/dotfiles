# Windows tools worth calling from WSL (appendWindowsPath=false in /etc/wsl.conf).
for d in \
  "/mnt/c/WINDOWS/system32" \
  "/mnt/c/WINDOWS" \
  "/mnt/c/Program Files/PowerShell/7" \
  "/mnt/c/Users/__WINUSER__/AppData/Local/Programs/Microsoft VS Code Insiders/bin" \
  "/mnt/c/Users/__WINUSER__/AppData/Local/Microsoft/WinGet/Links" \
  "/mnt/c/Program Files/glzr.io/GlazeWM/cli" \
  "/mnt/c/Program Files/glzr.io/Zebar"
do
  [ -d "$d" ] && case ":$PATH:" in *":$d:"*) ;; *) PATH="$PATH:$d" ;; esac
done
export PATH
