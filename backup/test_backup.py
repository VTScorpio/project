import os
import shutil
import backup  # asigură-te că backup.py și test_backup.py sunt în același folder

def test_backup_creation(tmp_path):
    # Setup
    os.environ["BACKUP_DIR"] = str(tmp_path / "backup")
    os.makedirs(os.environ["BACKUP_DIR"], exist_ok=True)
    test_file = tmp_path / "system-state.log"
    test_file.write_text("CPU Usage: 20%")

    # Rulează backupul manual
    shutil.copy(test_file, "system-state.log")
    backup.main()

    # Verificare
    backups = os.listdir(os.environ["BACKUP_DIR"])
    assert any(b.endswith(".log") for b in backups)
