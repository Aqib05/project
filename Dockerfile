FROM node:lts as builder

# Set the working directory
WORKDIR /app

# Copy the entire codebase to the working directory
COPY . .

# Set necessary environment variables
ENV NODE_ENV=production

# Install dependencies and clean cache
RUN rm -rf node_modules && \
    yarn install --prefer-offline --pure-lockfile --non-interactive --production=true && \
    yarn cache clean

# Debugging step: List installed node modules
RUN ls -alh node_modules

# Debugging step: Show package.json
RUN cat package.json

# Build the project
RUN yarn build-prod

FROM node:lts

# Environment variables for Puppeteer
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true
ENV PUPPETEER_EXECUTABLE_PATH "/usr/bin/google-chrome-stable"

# Install Chrome and necessary fonts
RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 sudo \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the build files from the builder stage
COPY --from=builder /app .

# Change permissions for the .next directory
RUN chmod -R 777 /app/.next

# Expose the application port
EXPOSE 3000

# Set the user to node
USER node

# Start the application
CMD ["yarn", "start"]
