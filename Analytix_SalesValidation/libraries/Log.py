# +
from datetime import datetime
import os


def write_log_text(log_type,log_reason,location,log_file_name):
    """
        type of log (exception/error etc), reason-note, location of file ,file name
        Ret:
        None
    """
    print(log_type,log_reason,location,log_file_name)
    now = datetime.now().strftime("%d/%m/%Y %H:%M:%S")
    line = str(now).ljust(16, ' ')+' '+str(log_type).ljust(16, ' ')+' '+str(log_reason)
    file_path = str(location)+'/'+str(log_file_name).strip()+'.txt'
    with open(file_path, "a") as outfile:
        outfile.write(line)
        outfile.write("\n")
# -


