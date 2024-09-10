FROM ubuntu:22.04

ENV PATH="/container/scripts:${PATH}"

RUN DEBIAN_FRONTEND=noninteractive \
 apt update && apt install runit avahi-daemon \
    samba samba-common samba-client wsdd2 libpam-krb5 krb5-user winbind \
    libnss-winbind libpam-winbind libpam-krb5 -y \
 && sed -i 's/#enable-dbus=.*/enable-dbus=no/g' /etc/avahi/avahi-daemon.conf \
 && rm -vf /etc/avahi/services/* \
 \
 && mkdir -p /external/avahi \
 && touch /external/avahi/not-mounted \
 && echo done

RUN echo [global]\
      krb5_auth = yes\
      krb5_ccache_type = FILE\
      >> /etc/security/pam_winbind.conf
#RUN update-crypto-policies --set DEFAULT:AD-SUPPORT

VOLUME ["/shares"]

EXPOSE 137/udp 139 445

COPY . /container/

HEALTHCHECK --interval=60s --timeout=15s \
 CMD smbclient -L \\localhost -U % -m SMB3

ENTRYPOINT ["/container/scripts/entrypoint.sh"]

CMD [ "runsvdir","-P", "/container/config/runit" ]