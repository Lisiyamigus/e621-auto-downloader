# e621-Smart-Queue-Downloader-
A powerful, multi-threaded Windows Batch & Python-powered downloader for e621. Featuring an interactive "Queue Wizard," automated character sorting, high-resolution file grabbing, and custom RGB UI themes.
✨ Key Features

    Smart Queue Wizard: Add multiple download jobs (characters, species, tags) before starting the process.

    Auto-Sorting: Files are automatically categorized into /images, /videos, and /gifs.

    "All" Search Intelligence: When searching by species, the script identifies character tags in each post and sorts them into dedicated character folders.

    High-Resolution Priority: Always fetches the original, best-quality file available.

    Safe Naming: Files are saved as Character_PostID.ext to prevent duplicates and stay organized.

    Custom RGB UI: Personalize your terminal with full 24-bit RGB color support.

🛠️ Installation & Setup
1. Prerequisites

Ensure you have the following installed on your Windows PC:

    Python 3.10+: Download here

    Git: Download here (Optional, for cloning)

2. Download the Project

3. Install Dependencies

Open your terminal/command prompt in the project folder and run:
Bash

pip install requests tqdm

or

py -m pip install requests tqdm

4. Configuration (API Key)

Open downloader.py in any text editor (Notepad, VS Code) and enter your credentials at the top:
Python

USERNAME = "Your_e621_Username"
API_KEY = "Your_e621_API_Key"

    Note: You can find your API key on your e621 account page under Account -> Setting -> API Key.

🚀 How to Use

    Launch: Double-click START_DOWNLOADER.bat.

    Add Jobs: Select [1] to enter the Wizard.

        Enter character name (or all for species-wide searches).

        Set rating (s, q, or e).

        Set score threshold (e.g., >100).

        Choose file type (image, video, gif, or all).

    Download: Once your queue is ready, select [2] to begin downloading.

    Enjoy: Check the /downloads folder for your perfectly organized files.

📂 Folder Structure

The script manages your library with surgical precision:
Plaintext

downloads/
└── Character_Name/
    ├── images/
    ├── videos/
    └── gifs/

⚖️ Disclaimer

This tool is for personal use only. Please respect e621's rate limits and terms of service. Using an API key is highly recommended to avoid being throttled as a guest.
