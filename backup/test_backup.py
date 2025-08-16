import os
from backup import perform_backup

def test_backup_creation(tmp_path):
    # Setăm căile de test
    backup_dir = tmp_path / "backup"
    log_file = tmp_path / "system-state.log"

    os.environ["BACKUP_DIR"] = str(backup_dir)
    os.environ["LOG_FILE"] = str(log_file)

    # Cream folderul și fișierul log
    os.makedirs(backup_dir, exist_ok=True)
    log_file.write_text("CPU Usage: 20%")

    # Apelăm funcția de backup
    perform_backup(None)

    # Verificăm backupul
    backups = os.listdir(backup_dir)
    assert any(b.endswith(".log") for b in backups), "Nu s-a creat niciun fișier de backup!"

    print(backups)
