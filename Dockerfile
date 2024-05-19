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

# Remember to create a Procfile in the root directory of your project with the following content:
# worker: sh -c "Xvfb :99 -screen 0 1024x768x16 && npm run harvest"