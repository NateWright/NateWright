---
title: "Nixos Nextcloud Setup"
date: 2023-10-19T16:21:31-04:00
draft: false
---

Tutorial on how to Setup Nixos, Tailscale, Nextcloud and Caddy with Cloudflare  
Take inspiration from [My Configuration](https://github.com/NateWright/nix-config/tree/master/devices/server)

 1. Download [Nixos](https://nixos.org/download.html#) Graphical Installer and Install
    * User tab select: `Use the same password for the administator account`
    * Desktop tab: Select no desktop environment or perferred
    * Unfree Software tab: Allow unfree software
    * Reboot and you should be able to login
 2. Enabling tailscale and ssh
    1. Open configuration `sudo nano /etc/nixos/configuration.nix`
    2. Modify `networking.hostname = "nixos";` to a reasonable name
    3. Add `tailscale' to packages
        ```nix
        environment.systemPackages = with pkgs; [
            tailscale
            vim 
            #  wget
        ];
        ```

    4. Add following code to file where you see fit
    
        ```nix
        services.tailscale.enable = true;
        networking.firewall = {
            # enable the firewall
            enable = true;

            # allow all ports from your Tailscale network
            trustedInterfaces = [ "tailscale0" ];
            #or allow you to SSH in over the public internet
            # allowedTCPPorts = [ 22 ];
            

            # allow the Tailscale UDP port through the firewall
            allowedUDPPorts = [ config.services.tailscale.port ];

        };
        services.openssh = {
            enable = true;
            # require public key authentication for better security
            settings = {
                PasswordAuthentication = false;
                KbdInteractiveAuthentication = false;
            };
            #permitRootLogin = "yes";
        };
        ```

    5. run `sudo nixos-rebuild switch` to change to our new config
    6. run `sudo tailscale up --ssh --qr` to authenticate and enable tailscale ssh
3. Setup Nextcloud
    1. Add a new file to `/etc/nixos` named nextcloud.nix
    2. Add following code to file
        ```nix
        { config, pkgs, ... }:
        {
        services.nextcloud = {
            enable = true;
            configureRedis = true;
            package = pkgs.nextcloud27;
            hostName = "nix-nextcloud";
            config = {
            dbtype = "pgsql";
            dbuser = "nextcloud";
            dbhost = "/run/postgresql"; # nextcloud will add /.s.PGSQL.5432 by itself
            dbname = "nextcloud";
            adminpassFile = "/etc/nixos/password.txt";
            adminuser = "root";
            trustedProxies = [ "localhost" "127.0.0.1" "YOUR_TAILSCALE_IP" "YOUR_DOMAIN" ];
            extraTrustedDomains = [ "YOUR_DOMAIN" ];
            overwriteProtocol = "https";
            };
        };

        services.postgresql = {
            enable = true;
            ensureDatabases = [ "nextcloud" ];
            ensureUsers = [
            { name = "nextcloud";
            ensurePermissions."DATABASE nextcloud" = "ALL PRIVILEGES";
            }
            ];
        };

        # ensure that postgres is running *before* running the setup
        systemd.services."nextcloud-setup" = {
            requires = ["postgresql.service"];
            after = ["postgresql.service"];
        };

        services.nginx.virtualHosts."nix-nextcloud".listen = [ { addr = "127.0.0.1"; port = 8009; } ];

        }
        ```
    3. Change YOUR_TAILSCALE_IP and YOUR_DOMAIN
    4. Add `./nextcloud.nix` to imports array of `configuration.nix`
    5. Add a temporary password to `/etc/nixos/password.txt`
    6. run `sudo nixos-rebuild switch` to change to our new config
4. Setup caddy
    1. Add a new file to `/etc/nixos` named caddy.nix
    2. Add following code to file
        ```nix
        { config, pkgs, ... }:
        {
        security.acme.acceptTerms = true;
        security.acme.defaults.email = "YOUR_CLOUDFLAIRE_EMAIL";
        security.acme.certs."YOUR_DOMAIN" = {
            dnsProvider = "cloudflare";
            credentialsFile = "/var/lib/secrets/cloudflare";
            extraDomainNames = [ "*.YOUR_DOMAIN" ];
        };
        services.caddy = {
            enable = true;
            user = "root";
            group = "root";
            virtualHosts = {
            "YOUR_DOMAIN" = {
                useACMEHost = "YOUR_DOMAIN";
                extraConfig = ''
                redir /.well-known/carddav /remote.php/dav 301
                redir /.well-known/caldav /remote.php/dav 301
                redir /.well-known/webfinger /index.php/.well-known/webfinger 301
                redir /.well-known/nodeinfo /index.php/.well-known/nodeinfo 301

                encode gzip
                reverse_proxy localhost:8009
                '';
            };
        };

        };
        }
        ```
    3. Change YOUR_DOMAIN
    4. Make a file named `/var/lib/secrets/cloudflare` with contents and add your keys from cloudflare api
        ```
        CLOUDFLARE_DNS_API_TOKEN=
        CLOUDFLARE_ZONE_API_TOKEN=
        ```
    5. Add `./caddy.nix` to imports array of `configuration.nix`
    6. run `sudo nixos-rebuild switch` to change to our new config
5. Login to nextcloud with admin and initial password you set. Change password and make a new account for yourself