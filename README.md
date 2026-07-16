# Saffron & Stone Landing Page

A polished restaurant landing page built with HTML, CSS, and JavaScript.

## Local preview

Run the local server:

```powershell
cd "c:\Users\Glow Computers\Desktop\duromnm\project 1"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\static-server.ps1
```

Open:

```
http://127.0.0.1:8080
```

## Live tunnel

If you want a temporary public URL, run:

```powershell
cd "c:\Users\Glow Computers\Desktop\duromnm\project 1"
.\cloudflared.exe tunnel --url http://127.0.0.1:8080/
```

## GitHub Pages deploy

1. Create a GitHub repository.
2. Add remote and push:

```powershell
cd "c:\Users\Glow Computers\Desktop\duromnm\project 1"
git remote add origin https://github.com/<your-username>/<repo>.git
git push -u origin master
```

3. Enable GitHub Pages on the `master` branch in repository settings.
