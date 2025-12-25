# Build stage
FROM node:18-alpine as build

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies with legacy peer deps
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Set environment variable for API URL
ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=${REACT_APP_API_URL:-https://tugas-cc-480903.de.r.appspot.com}

# Build app with legacy OpenSSL - run node directly with flag
RUN node --openssl-legacy-provider node_modules/.bin/react-scripts build

# Production stage
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built app
COPY --from=build /app/build /usr/share/nginx/html

# Expose port 8080 (Cloud Run default)
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
