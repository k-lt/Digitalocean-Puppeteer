FROM node:20

# Configure default locale (important for chrome-headless-shell). 
ENV LANG en_US.UTF-8

RUN apt-get update && apt-get install -y \
    wget \
    gnupg \
    npm \
    && wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/google-linux-signing-key.gpg \
    && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux-signing-key.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable \
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
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g npm@latest

# Create user to run the app
RUN groupadd -r pptruser && useradd -rm -g pptruser -G audio,video pptruser

# Give user permissions
RUN mkdir -p /var/run \ 
    && chown pptruser:pptruser /var/run 

# Set the working directory
WORKDIR /app
COPY . /app

# Set environment variables
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV DBUS_SESSION_BUS_ADDRESS=autolaunch:

# Clear npm cache
RUN npm cache clean --force

# Expose the port the app runs on
#EXPOSE 3000

# Install npm dependencies
#RUN cd /app && npm install

# Set up a screen
#
# This is potentially the run command that will be executed when the container starts.
# It starts a virtual screen and runs the harvest script.
#

# Command to start the application

# Command to start Xvfb and keep the container running
CMD ["sh", "-c", "Xvfb :99 -screen 0 1024x768x16 & tail -f /dev/null"]