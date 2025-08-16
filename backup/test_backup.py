import os
import importlib
import backup

def test_backup_creation(tmp_path):
    backup_dir = tmp_path / "backup"
    log_file = tmp_path / "system-state.log"

    os.environ["BACKUP_DIR"] = str(backup_dir)
    os.environ["LOG_FILE"] = str(log_file)

    os.makedirs(backup_dir, exist_ok=True)
    log_file.write_text("CPU Usage: 20%")

    importlib.reload(backup)  # reîncarcă LOG_FILE după setarea ENV
    backup.perform_backup(None)

    backups = os.listdir(backup_dir)
    assert any(b.endswith(".log") for b in backups), "Nu s-a creat niciun fișier de backup!"

    print("LOG_FILE:", os.getenv("LOG_FILE"))
    print("BACKUP_DIR:", os.getenv("BACKUP_DIR"))
    print("LOG_FILE exists?", os.path.exists(os.getenv("LOG_FILE")))
