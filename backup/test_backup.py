import os
import shutil
import backup

dimport backup

def test_backup_creation(tmp_path):
    backup_dir = tmp_path / "backup"
    log_file = tmp_path / "system-state.log"
    
    os.environ["BACKUP_DIR"] = str(backup_dir)
    os.environ["LOG_FILE"] = str(log_file)

    os.makedirs(backup_dir, exist_ok=True)
    log_file.write_text("CPU Usage: 20%")

    backup.perform_backup()  # rulează doar o dată, fără while True

    backups = os.listdir(backup_dir)
    assert any(b.endswith(".log") for b in backups)
