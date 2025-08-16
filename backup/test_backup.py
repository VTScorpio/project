import os
import backup  # asigură-te că backup.py și test_backup.py sunt în același folder
from pathlib import Path

def test_backup_creation(tmp_path):
    # Setăm căile de test
    backup_dir = tmp_path / "backup"
    log_file = tmp_path / "system-state.log"

    # Setăm variabilele de mediu
    os.environ["BACKUP_DIR"] = str(backup_dir)
    os.environ["LOG_FILE"] = str(log_file)

    # Cream folderul și fișierul log
    os.makedirs(backup_dir, exist_ok=True)
    log_file.write_text("CPU Usage: 20%")

    # Apelăm funcția de backup care face o singură rulare
    backup.perform_backup()

    # Verificăm că în folderul de backup s-a creat un fișier .log
    backups = os.listdir(backup_dir)
    assert any(b.endswith(".log") for b in backups), "Nu s-a creat niciun fișier de backup!"
