import os
import time
import shutil
from datetime import datetime
import logging
import hashlib

LOG_FILE = os.getenv("LOG_FILE", "data/system-state.log")
BACKUP_DIR = os.getenv("BACKUP_DIR", "backup-data")
INTERVAL = int(os.getenv("BACKUP_INTERVAL", 5))

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s: %(message)s")

def get_file_hash(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        h.update(f.read())
    return h.hexdigest()

def perform_backup(last_hash=None):
    if not os.path.exists(LOG_FILE):
        logging.warning(f"{LOG_FILE} nu exista.")
        return last_hash

    current_hash = get_file_hash(LOG_FILE)

    if current_hash != last_hash:
        os.makedirs(BACKUP_DIR, exist_ok=True)
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"system-state_{timestamp}.log"
        dest = os.path.join(BACKUP_DIR, backup_name)
        shutil.copy(LOG_FILE, dest)
        logging.info(f"Backup creat: {dest}")
        return current_hash
    else:
        logging.info("Nicio modificare detectata, backup omis.")
        return last_hash

def main():
    last_hash = None
    while True:
        try:
            last_hash = perform_backup(last_hash)
        except Exception as e:
            logging.error(f"Eroare: {e}")
        time.sleep(INTERVAL)

if __name__ == "__main__":
    main()
