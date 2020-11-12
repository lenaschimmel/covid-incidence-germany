FROM alpine
RUN apk add --no-cache curl gzip coreutils bash tzdata

# Download and extract xsv, a tool for handling csv files
RUN curl -L -O https://github.com/BurntSushi/xsv/releases/download/0.13.0/xsv-0.13.0-x86_64-unknown-linux-musl.tar.gz
RUN gzip -d xsv-0.13.0-x86_64-unknown-linux-musl.tar.gz
RUN tar -xvf xsv-0.13.0-x86_64-unknown-linux-musl.tar
RUN cp xsv /usr/bin

# Apply cron job
COPY crontab.txt /etc/cron.d/crontab.txt
RUN crontab /etc/cron.d/crontab.txt

# Set timezone
RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Copy script and basisdaten
COPY . .

# This should help check the timezone
RUN date

# Run the script which initializes stuff and then runs cron
CMD ./command.sh