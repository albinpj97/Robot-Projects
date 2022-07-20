import glob,os

def lib_remove_all_csv_files(path):
     os.chdir(path)
     for file in glob.glob("*.csv"):
        os.remove(file)
     for file in glob.glob("*.CSV"):
        os.remove(file)
        # os.rename('/Users/billy/d1/xfile.txt', '/Users/billy/d2/xfile.txt')



 