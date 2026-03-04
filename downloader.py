import os, requests, sys, json
from tqdm import tqdm

USERNAME = "YourUsernameHere"
API_KEY = "YourApiKeyHere"

def get_smart_query(job):
    query = []
    char = job["char"].lower()
    if char not in ["all", "none", ""]:
        query.append(job["char"])
    if (char in ["all", "none", ""]) and job["spec"] != "none":
        query.append(job["spec"])
    elif job["spec"] != "none" and job["spec"] != "":
        query.append(job["spec"])

    if job["rate"] and job["rate"] != "any": query.append(f"rating:{job['rate']}")
    if job["qual"]: query.append(f"score:{job['qual']}")
    
    inc_img = job.get("inc_img", "y")
    inc_vid = job.get("inc_vid", "y")
    inc_gif = job.get("inc_gif", "y")

    if inc_img == "n": query.append("-type:jpg -type:png")
    if inc_vid == "n": query.append("-type:webm -type:mp4")
    if inc_gif == "n": query.append("-type:gif")

    if job["tags"]: query.append(job["tags"].replace(";", " "))
    if job["black"]:
        for t in job["black"].split(';'):
            if t.strip(): query.append(f"-{t.strip()}")
    return " ".join(query)

def download_queue():
    if not os.path.exists("queue.json"): return
    auth = (USERNAME, API_KEY) if USERNAME != "YourUsernameHere" else None
    with open("queue.json", "r") as f:
        queue = json.load(f)

    for job in queue:
        tags = get_smart_query(job)
        is_all_search = job["char"].lower() == "all"
        
        # Hard Force: Convert the limit to a clean integer
        try:
            target_limit = int(job["lim"])
        except:
            target_limit = 10 
        
        downloaded_count = 0
        print(f"\n [QUEUE] Searching: {tags} | Target: {target_limit}")
        
        try:
            # CRITICAL FIX: The URL now passes the EXACT limit to e621
            url = f"https://e621.net/posts.json?tags={tags}&limit={target_limit}"
            resp = requests.get(url, headers={"User-Agent": "SmartQueue/1.0"}, auth=auth)
            posts = resp.json().get('posts', [])
            
            # Use the actual number of posts returned (in case it's less than the limit)
            actual_count = min(len(posts), target_limit)
            pbar = tqdm(total=actual_count, desc=" Saving", bar_format="{l_bar}{bar:20}{r_bar}")
            
            for post in posts:
                if downloaded_count >= target_limit:
                    break
                
                f_url = post.get('file', {}).get('url')
                if not f_url: continue 
                
                char_tags = post.get('tags', {}).get('character', [])
                if is_all_search and char_tags:
                    folder_name = char_tags[0] if len(char_tags) == 1 else "multiple_characters"
                else:
                    folder_name = job["char"] if job["char"] != "all" else job["spec"]
                
                clean_folder = folder_name.replace(" ", "_")
                ext = post['file']['ext'].lower()
                sub = "videos" if ext in ['webm', 'mp4'] else "gifs" if ext == 'gif' else "images"
                
                final_dir = os.path.join("downloads", clean_folder, sub)
                os.makedirs(final_dir, exist_ok=True)
                
                filename = f"{clean_folder}_{post['id']}.{ext}"
                full_path = os.path.join(final_dir, filename)
                
                if not os.path.exists(full_path):
                    content = requests.get(f_url).content
                    with open(full_path, "wb") as f_img:
                        f_img.write(content)
                
                downloaded_count += 1
                pbar.update(1)
            
            pbar.close()
        except Exception as e: print(f" [!] Error: {e}")

if __name__ == "__main__":
    download_queue()
