from datetime import datetime
from RPA.Robocorp.Vault import Vault

# +
TODAY = datetime.now()

orange_hr_cred = Vault().get_secret("orange_hr_credentials")

Or_Hr_USER_NAME = orange_hr_cred["username"]
print(Or_Hr_USER_NAME)
Or_Hr_PASSWORD = orange_hr_cred["password"]
