FROM ubuntu:18.04 AS builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y \
                    build-essential \
                    bison \
                    telnet \
                    ncompress \
                    wget

# Copy in the LambdaMOO source code to build
COPY . /tmp
WORKDIR /tmp

# Build LambdaMOO
RUN ./configure && \
    make

# Final image
FROM ubuntu:18.04 AS moo

# Copy in the compiled LambdaMOO binary
COPY --from=builder /tmp/moo /bin/moo

# Copy in the absolute minimal databse core (for testing)
# (Most users will want to mount their own db based on LambdaCore instead)
COPY ./Minimal.db /db/lambdamoo.db

# Hint at mountpoint and port
VOLUME /db
EXPOSE 7777

ENTRYPOINT ["/bin/moo"]
CMD ["/db/lambdamoo.db", "/db/lambdamoo.db.new"]