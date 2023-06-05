"""
MIT License

Copyright (c) 2023 Paolo Salvatori

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"""

# This sample is based on the following article:
#
# - https://levelup.gitconnected.com/its-time-to-create-a-private-chatgpt-for-yourself-today-6503649e7bb6
#
# Use pip to install the following packages:
#
# - streamlit
# - openai
# - streamlit-chat
# - azure.identity
# - dotenv
#
# Make sure to provide a value for the following environment variables:
#
# - AZURE_OPENAI_BASE: the URL of your Azure OpenAI resource, for example https://eastus.api.cognitive.microsoft.com/
# - AZURE_OPENAI_KEY: the key of your Azure OpenAI resource
# - AZURE_OPENAI_DEPLOYMENT: the name of the ChatGPT deployment used by your Azure OpenAI resource
# - AZURE_OPENAI_MODEL: the name of the ChatGPT model used by your Azure OpenAI resource, for example gpt-35-turbo
# - TITLE: the title of the Streamlit app
# - TEMPERATURE: the temperature used by the OpenAI API to generate the response
# - SYSTEM: give the model instructions about how it should behave and any context it should reference when generating a response. 
#   Used to describe the assistant's personality.
#
# You can use two different authentication methods:
# 
# - API key: set the AZURE_OPENAI_TYPE environment variable to azure and the AZURE_OPENAI_KEY environment variable to the key of  
#   your Azure OpenAI resource. You can use the regional endpoint, such as https://eastus.api.cognitive.microsoft.com/, passed in 
#   the AZURE_OPENAI_BASE environment variable, to connect to the Azure OpenAI resource.
# - Azure Active Directory: set the AZURE_OPENAI_TYPE environment variable to azure_ad and use a service principal or managed 
#   identity with the DefaultAzureCredential object to acquire a token. For more information on the DefaultAzureCredential in Python, 
#   see https://docs.microsoft.com/en-us/azure/developer/python/azure-sdk-authenticate?tabs=cmd
#   Make sure to assign the "Cognitive Services User" role to the service principal or managed identity used to authenticate to 
#   Azure OpenAI. For more information, see https://learn.microsoft.com/en-us/azure/cognitive-services/openai/how-to/managed-identity.
#   If you want to use Azure AD integrated security, you need to create a custom subdomain for your Azure OpenAI resource and use the 
#   specific endpoint containing the custom domain, such as https://bingo.openai.azure.com/ where bingo is the custom subdomain. 
#   If you specify the regional endpoint, you get a wonderful error: "Subdomain does not map to a resource.". 
#   Hence, make sure to pass the endpoint containing the custom domain in the AZURE_OPENAI_BASE environment variable.
#
# Use the following command to run the app: 
# 
# - streamlit run app.py

# Import packages
import os
import sys
import time
import openai
import logging
import streamlit as st
from streamlit_chat import message
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv
from dotenv import dotenv_values

# Load environment variables from .env file
if os.path.exists(".env"):
  load_dotenv(override=True)
  config = dotenv_values(".env")

# Read environment variables
assistan_profile = """
You are the infamous Magic 8 Ball. You need to randomly reply to any question with one of the following answers:

- It is certain.
- It is decidedly so.
- Without a doubt.
- Yes definitely.
- You may rely on it.
- As I see it, yes.
- Most likely.
- Outlook good.
- Yes.
- Signs point to yes.
- Reply hazy, try again.
- Ask again later.
- Better not tell you now.
- Cannot predict now.
- Concentrate and ask again.
- Don't count on it.
- My reply is no.
- My sources say no.
- Outlook not so good.
- Very doubtful.

Add a short comment in a pirate style at the end! Follow your heart and be creative! 
For mor information, see https://en.wikipedia.org/wiki/Magic_8_Ball
"""
title = os.environ.get("TITLE", "Magic 8 Ball")
text_input_label = os.environ.get("TEXT_INPUT_LABEL", "Pose your question and cross your fingers!")
image_file_name = os.environ.get("IMAGE_FILE_NAME", "magic8ball.png")
image_width = int(os.environ.get("IMAGE_WIDTH", 80))
temperature = float(os.environ.get("TEMPERATURE", 0.9))
system = os.environ.get("SYSTEM", assistan_profile)
api_base = os.getenv("AZURE_OPENAI_BASE")
api_key = os.getenv("AZURE_OPENAI_KEY")
api_type = os.environ.get("AZURE_OPENAI_TYPE", "azure")
api_version = os.environ.get("AZURE_OPENAI_VERSION", "2023-05-15")
engine = os.getenv("AZURE_OPENAI_DEPLOYMENT")
model = os.getenv("AZURE_OPENAI_MODEL")

# Configure OpenAI
openai.api_type = api_type
openai.api_version = api_version
openai.api_base = api_base 

# Set default Azure credential
default_credential = DefaultAzureCredential() if openai.api_type == "azure_ad" else None

# Configure a logger
logging.basicConfig(stream = sys.stdout, 
                    format = '[%(asctime)s] {%(filename)s:%(lineno)d} %(levelname)s - %(message)s',
                    level = logging.INFO)
logger = logging.getLogger(__name__)

# Log variables
logger.info(f"title: {title}")
logger.info(f"text_input_label: {text_input_label}")
logger.info(f"image_file_name: {image_file_name}")
logger.info(f"image_width: {image_width}")
logger.info(f"temperature: {temperature}")
logger.info(f"system: {system}")
logger.info(f"api_base: {api_base}")
logger.info(f"api_key: {api_key}")
logger.info(f"api_type: {api_type}")
logger.info(f"api_version: {api_version}")
logger.info(f"engine: {engine}")
logger.info(f"model: {model}")

# Authenticate to Azure OpenAI
if openai.api_type == "azure":
  openai.api_key = api_key
elif openai.api_type == "azure_ad":
  openai_token = default_credential.get_token("https://cognitiveservices.azure.com/.default")
  openai.api_key = openai_token.token
  if 'openai_token' not in st.session_state:
    st.session_state['openai_token'] = openai_token
else:
  logger.error("Invalid API type. Please set the AZURE_OPENAI_TYPE environment variable to azure or azure_ad.")
  raise ValueError("Invalid API type. Please set the AZURE_OPENAI_TYPE environment variable to azure or azure_ad.")

# Customize Streamlit UI using CSS
st.markdown("""
<style>

div.stButton > button:first-child {
    background-color: #eb5424;
    color: white;
    font-size: 20px;
    font-weight: bold;
    border-radius: 0.5rem;
    padding: 0.5rem 1rem;
    border: none;
    box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.15);
    width: 300 px;
    height: 42px;
    transition: all 0.2s ease-in-out;
} 

div.stButton > button:first-child:hover {
    transform: translateY(-3px);
    box-shadow: 0 1rem 2rem rgba(0,0,0,0.15);
}

div.stButton > button:first-child:active {
    transform: translateY(-1px);
    box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.15);
}

div.stButton > button:focus:not(:focus-visible) {
    color: #FFFFFF;
}

@media only screen and (min-width: 768px) {
  /* For desktop: */
  div {
      font-family: 'Roboto', sans-serif;
  }

  div.stButton > button:first-child {
      background-color: #eb5424;
      color: white;
      font-size: 20px;
      font-weight: bold;
      border-radius: 0.5rem;
      padding: 0.5rem 1rem;
      border: none;
      box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.15);
      width: 300 px;
      height: 42px;
      transition: all 0.2s ease-in-out;
      position: relative;
      bottom: -32px;
      right: 0px;
  } 

  div.stButton > button:first-child:hover {
      transform: translateY(-3px);
      box-shadow: 0 1rem 2rem rgba(0,0,0,0.15);
  }

  div.stButton > button:first-child:active {
      transform: translateY(-1px);
      box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.15);
  }

  div.stButton > button:focus:not(:focus-visible) {
      color: #FFFFFF;
  }

  input {
      border-radius: 0.5rem;
      padding: 0.5rem 1rem;
      border: none;
      box-shadow: 0 0.5rem 1rem rgba(0,0,0,0.15);
      transition: all 0.2s ease-in-out;
      height: 40px;
  }
}
</style>
""", unsafe_allow_html=True)

# Initialize Streamlit session state
if 'prompts' not in st.session_state:
  st.session_state['prompts'] = [{"role": "system", "content": system}]

if 'generated' not in st.session_state:
  st.session_state['generated'] = []

if 'past' not in st.session_state:
  st.session_state['past'] = []

# Refresh the OpenAI security token every 45 minutes
def refresh_openai_token():
  if st.session_state['openai_token'].expires_on < int(time.time()) - 45 * 60:
      st.session_state['openai_token'] = default_credential.get_token("https://cognitiveservices.azure.com/.default")
      openai.api_key = st.session_state['openai_token'].token

# Send user prompt to Azure OpenAI 
def generate_response(prompt):
  try:
    st.session_state['prompts'].append({"role": "user", "content": prompt})

    if openai.api_type == "azure_ad":
      refresh_openai_token()

    completion = openai.ChatCompletion.create(
      engine = engine,
      model = model,
      messages = st.session_state['prompts'],
      temperature = temperature,
    )
    
    message = completion.choices[0].message.content
    return message
  except Exception as e:
    logging.exception(f"Exception in generate_response: {e}")

# Reset Streamlit session state to start a new chat from scratch
def new_click():
  st.session_state['prompts'] = [{"role": "system", "content": system}]
  st.session_state['past'] = []
  st.session_state['generated'] = []
  st.session_state['user'] = ""

# Handle on_change event for user input
def user_change():
  # Avoid handling the event twice when clicking the Send button
  chat_input = st.session_state['user']
  st.session_state['user'] = ""
  if (chat_input == '' or
      (len(st.session_state['past']) > 0 and chat_input == st.session_state['past'][-1])):
    return
  
  # Generate response invoking Azure OpenAI LLM
  if chat_input !=  '':
    output = generate_response(chat_input)
    
    # store the output
    st.session_state['past'].append(chat_input)
    st.session_state['generated'].append(output)
    st.session_state['prompts'].append({"role": "assistant", "content": output})

# Create a 2-column layout. Note: Streamlit columns do not properly render on mobile devices.
# For more information, see https://github.com/streamlit/streamlit/issues/5003
col1, col2 = st.columns([1, 7])

# Display the robot image
with col1:
  st.image(image = os.path.join("images", image_file_name), width = image_width)

# Display the title
with col2:
  st.title(title)

# Create a 3-column layout. Note: Streamlit columns do not properly render on mobile devices.
# For more information, see https://github.com/streamlit/streamlit/issues/5003
col3, col4, col5 = st.columns([7, 1, 1])

# Create text input in column 1
with col3:
  user_input = st.text_input(text_input_label, key = "user", on_change = user_change)

# Create send button in column 2
with col4:
  st.button(label = "Send")

# Create new button in column 3
with col5:
  st.button(label = "New", on_click = new_click)

# Display the chat history in two separate tabs
# - normal: display the chat history as a list of messages using the streamlit_chat message() function 
# - rich: display the chat history as a list of messages using the Streamlit markdown() function
if st.session_state['generated']:
  tab1, tab2 = st.tabs(["normal", "rich"])
  with tab1:
    for i in range(len(st.session_state['generated']) - 1, -1, -1):
      message(st.session_state['past'][i], is_user = True, key = str(i) + '_user', avatar_style = "fun-emoji", seed = "Nala")
      message(st.session_state['generated'][i], key = str(i), avatar_style = "bottts", seed = "Fluffy")
  with tab2:
    for i in range(len(st.session_state['generated']) - 1, -1, -1):
      st.markdown(st.session_state['past'][i])
      st.markdown(st.session_state['generated'][i])