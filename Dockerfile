FROM node:lts as builder

# Install latest chrome dev package and fonts to support major charsets (Chinese, Japanese, Arabic, Hebrew, Thai and a few others)
# Note: this installs the necessary libs to make the bundled version of Chromium that Puppeteer
# installs, work.

WORKDIR /app

COPY . .

RUN rm -rf node_modules && \
  NODE_ENV=production yarn install  && yarn cache clean \
  --prefer-offline \
  --pure-lockfile \
  --non-interactive \
  --production=true

RUN yarn build-prod

FROM node:lts
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH "/usr/bin/google-chrome-stable"

RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 sudo \
      --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /app

COPY --from=builder /app  .
RUN chmod -R 777 /app/.next
EXPOSE 3000
USER node
COPY --chown=node:node . .
EXPOSE 3000

CMD yarn start
