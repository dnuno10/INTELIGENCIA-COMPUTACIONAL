import os
from dotenv import load_dotenv
from openai import OpenAI

SYSTEM_MESSAGE = "You are a chatbot. You will have a conversation with a user. Be friendly and concise"

if __name__ == "__main__":
    load_dotenv()

    URL = os.environ.get("OPENROUTER_BASE_URL")
    KEY = os.environ.get("OPENROUTER_KEY")
    MODEL = os.environ.get("MODEL")

    client = OpenAI(
        base_url=URL,
        api_key=KEY,
    )

    messages = [
        {"role": "system", "content": SYSTEM_MESSAGE}
    ]

    print(f"Chatting with {MODEL} model at {URL}\n")

    while True:
        message = input("> ")

        messages.append({
            "role": "user",
            "content": message
        })

        response = client.chat.completions.create(
            model=MODEL,
            max_tokens=300,
            messages=messages
        )

        assistant_message = response.choices[0].message.content

        messages.append({
            "role": "assistant",
            "content": assistant_message
        })

        print(assistant_message)