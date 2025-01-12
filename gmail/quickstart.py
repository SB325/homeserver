import os.path
import pdb

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/gmail.readonly"]


def refresh_token():
  """Shows basic usage of the Gmail API.
  Lists the user's Gmail labels.
  """
  creds = None
  # The file token.json stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  if os.path.exists("token.json"):
    creds = Credentials.from_authorized_user_file("token.json", SCOPES)
  # If there are no (valid) credentials available, let the user log in.
  if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
      creds.refresh(Request())
    else:
      flow = InstalledAppFlow.from_client_secrets_file(
          "credentials.json", SCOPES
      )
      creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open("token.json", "w") as token:
      token.write(creds.to_json())

def get_label(getlabel: str = None) -> list:
  if os.path.exists("token.json"):
    creds = Credentials.from_authorized_user_file("token.json", SCOPES)
  try:
    # Call the Gmail API
    service = build("gmail", "v1", credentials=creds)
    results = service.users().labels().list(userId="me").execute()
    labels = results.get("labels", [])

    if not labels:
      print("No labels found.")
      return
    print("Labels:")
    labeldict = [label for label in labels if 'ThinkorSwim' in label.get('name', None)]
    return labeldict[0].get('id', None)

  except HttpError as error:
    # TODO(developer) - Handle errors from gmail API.
    print(f"An error occurred: {error}")

def get_emails(query: str = None):
  if os.path.exists("token.json"):
    creds = Credentials.from_authorized_user_file("token.json", SCOPES)
  try:
    # Call the Gmail API
    service = build("gmail", "v1", credentials=creds) 
    results = service.users().messages().list(userId="me", q=query).execute()

    messages = results.get('messages', None)
    msg_list = []
    if messages:
      for message in messages:
        msg = service.users().messages().get(userId="me", id=message['id']).execute()
        msg_list.append(
            {
              'id': msg['id'], 
              'snippet': msg['snippet'],
              'subject': [val['value'] for val in msg['payload']['headers'] 
                  if 'Subject' in val['name']][0]
            }
        )

  except HttpError as error:
    # TODO(developer) - Handle errors from gmail API.
    print(f"An error occurred: {error}")

  return msg_list


if __name__ == "__main__":
  refresh_token()
  email_list = get_emails("alerts@thinkorswim.com")