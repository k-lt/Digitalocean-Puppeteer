# Puppeteer - Dockerfile

<img src="https://ka.lt/images/github/dockerfile.svg" alt="" width="100%" height="auto">

Based on the [official Dockerfile from Puppeteer](https://github.com/puppeteer/puppeteer/blob/main/docker/Dockerfile), which did not work for our use case for deploying to [Digital Ocean](https://m.do.co/c/2dfff08eb162).


## Dockerfile before compilation

```Dockerfile
FROM node:20

# Configure default locale (important for chrome-headless-shell)
ENV LANG en_US.UTF-8

# Install dependencies and Google Chrome
RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-key.gpg \
    && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-key.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update && apt-get install -y \
    google-chrome-stable \
    fonts-ipafont-gothic \
    fonts-wqy-zenhei \
    fonts-thai-tlwg \
    fonts-khmeros \
    fonts-kacst \
    fonts-freefont-ttf \
    libxss1 \
    dbus \
    dbus-x11 \
    xvfb \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install latest npm globally
RUN npm install -g npm@latest

# Create user to run the app
RUN groupadd -r pptruser && useradd -rm -g pptruser -G audio,video pptruser

# Give user permissions
RUN mkdir -p /var/run && chown pptruser:pptruser /var/run

# Set the working directory
WORKDIR /app
COPY . /app

# Set environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV DBUS_SESSION_BUS_ADDRESS=autolaunch:
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/google-chrome-stable

# Clear npm cache
RUN npm cache clean --force

# Install npm dependencies
RUN npm install

# Initate the screen required for headless chrome
CMD ["sh", "-c", "Xvfb :99 -screen 0 1024x768x16"]

```

## Compiling docker image
Remember to replace Kalt with your orgname or username, and dockerfile with repo name.

1. Run `docker build -t ghcr.io/k-lt/dockerfile:latest .`
2. Run `docker push ghcr.io/k-lt/dockerfile:latest`