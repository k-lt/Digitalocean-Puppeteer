FROM node:20

# Configure default locale (important for chrome-headless-shell). 
ENV LANG en_US.UTF-8

RUN apt-get update \
    && apt-get install -y wget gnupg cron npm \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg \
    && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] https://dl-ssl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1 dbus dbus-x11 \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Create user to run the app
RUN groupadd -r pptruser && useradd -rm -g pptruser -G audio,video pptruser

USER pptruser

WORKDIR /app
COPY . /app


ENV DBUS_SESSION_BUS_ADDRESS autolaunch:

# Create a cron job that changes to the app directory before running the npm command
RUN echo "5 * * * * cd /app && npm run harvest-auctions >> /var/log/cron.log 2>&1" > /etc/cron.d/harvest-cron
RUN chmod 0644 /etc/cron.d/harvest-cron
RUN crontab /etc/cron.d/harvest-cron
RUN touch /var/log/cron.log

# Install @puppeteer/browsers, puppeteer and puppeteer-core into /app/node_modules.
RUN cd /app && npm i puppeteer-core puppeteer @puppeteer/browsers\
    && (node -e "require('child_process').execSync(require('puppeteer').executablePath() + ' --credits', {stdio: 'inherit'})" > THIRD_PARTY_NOTICES)

RUN cd /app && npm ci

CMD ["cron", "-f"]