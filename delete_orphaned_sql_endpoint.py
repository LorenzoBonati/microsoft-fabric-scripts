import requests

# ==== PARAMETERS TO FILL IN ====
artifact_id = "<PUT-ARTIFACT-ID-HERE>"   # e.g. "ca28a0a1-4e20-4f00-a390-5711adb6a5a9"
host_url    = "<PUT-HOST-URL-HERE>"      # e.g. "wabi-westeurope-redirect.analysis.windows.net"
# =================================

# Get Fabric backend token
bearer = mssparkutils.credentials.getToken("https://analysis.windows.net/powerbi/api")

# Attach Authorization header
headers = {
    "Authorization": f"Bearer {bearer}"
}

# Build request URL
url = f"https://{host_url}/metadata/artifacts/{artifact_id}"

# Execute DELETE call
response = requests.delete(url, headers=headers)

# Show result
print("Status:", response.status_code)
print("Response:", response.text)
