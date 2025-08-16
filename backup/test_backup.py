import os
import shutil
import backup

def test_backup_creation(tmp_path):
    backup_dir = tmp_path / "/backup-data"
    print(backup_dir)
    log_file = tmp_path / "system-state.log"
    print(log_file)
    
    os.environ["BACKUP_DIR"] = str(backup_dir)
    os.environ["LOG_FILE"] = str(log_file)

    os.makedirs(backup_dir, exist_ok=True)
    log_file.write_text("CPU Usage: 20%")

    # Rulează backupul
    backup.perform_backup()

    backups = os.listdir(backup_dir)
    assert any(b.endswith(".log") for b in backups)