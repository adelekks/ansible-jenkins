FROM adelekks/jenkins_image
RUN rm -rf /run/systemd/generator.late
RUN /sbin/chkconfig jenkins on 

# Without this, init won't start the enabled services and exec'ing and starting
# them reports "Failed to get D-Bus connection: Operation not permitted".
VOLUME /run /tmp
EXPOSE 8080 5000
# Don't know if it's possible to run services without starting this
CMD ["/usr/sbin/init"]
