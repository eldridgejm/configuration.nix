{ pkgs, ... }:

{
  services.restic.backups = {

    home-local = {
      passwordFile = "/etc/nixos/restic-password";
      paths = [
        "/home/eldridge/"
      ];
      repository = "/backup/alamere-home";
      extraBackupArgs = [
        "--verbose"
        "--exclude='*.cache/*'"
        "--exclude='*/cache/*'"
        "--exclude='*/lost+found/*'"
        "--exclude='github-runner/*'"
        "--exclude='/home/eldridge/mnt'"
        "--exclude='/home/eldridge/downloads'"
        "--exclude='/home/eldridge/sandbox'"
        "--exclude='*VirtualBox*'"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
      };
    };

    home-remote = {
      passwordFile = "/etc/nixos/restic-password";
      paths = [
        "/home/eldridge"
      ];
      repository = "b2:Eldridge-Backup:alamere-home";
      extraBackupArgs = [
        "--verbose"
        "--exclude='*.cache/*'"
        "--exclude='*/cache/*'"
        "--exclude='*/lost+found/*'"
        "--exclude='github-runner/*'"
        "--exclude='/home/eldridge/mnt'"
        "--exclude='/home/eldridge/downloads'"
        "--exclude='/home/eldridge/sandbox'"
        "--exclude='*VirtualBox*'"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 04:00:00";
      };
    };

    etc-local = {
      passwordFile = "/etc/nixos/restic-password";
      paths = [
        "/etc"
      ];
      repository = "/backup/alamere-etc";
      extraBackupArgs = [
        "--verbose"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 02:00:00";
      };
    };

    etc-remote = {
      passwordFile = "/etc/nixos/restic-password";
      initialize = true;
      paths = [
        "/etc"
      ];
      repository = "b2:Eldridge-Backup:alamere-etc";
      extraBackupArgs = [
        "--verbose"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 02:00:00";
      };
    };

    dc-local = {
      passwordFile = "/etc/nixos/restic-password";
      paths = [
        "/mnt/dc/photos" "/mnt/dc/archive" "/mnt/dc/.backup-tester"
      ];
      repository = "/backup/dc";
      extraBackupArgs = [
        "--verbose"
        "--exclude='*.cache/*'"
        "--exclude='*/cache/*'"
        "--exclude='*/lost+found/*'"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 03:30:00";
      };
    };

    dc-remote = {
      passwordFile = "/etc/nixos/restic-password";
      initialize = true;
      paths = [
        "/mnt/dc/photos" "/mnt/dc/archive" "/mnt/dc/.backup-tester"
      ];
      repository = "b2:Eldridge-Backup:dc";
      extraBackupArgs = [
        "--verbose"
        "--exclude='*.cache/*'"
        "--exclude='*/cache/*'"
        "--exclude='*/lost+found/*'"
        "--exclude='*/autc/*'"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 24"
        "--keep-yearly 75"
      ];

      timerConfig = {
        OnCalendar = "*-*-* 04:30:00";
      };
    };

  };

  systemd.services.backup-tester-home = rec {
    description = "Create a file with the current time for use when checking backups.";
    startAt = "hourly";
    environment = {
      inherit (config.environment.variables);
    };

    serviceConfig = {
      User = "eldridge";
      ExecStart = "${pkgs.bash}/bin/bash -c 'date > /home/eldridge/.backup-tester'";
    };
  };

  systemd.services.backup-tester-etc = rec {
    description = "Create a file with the current time for use when checking backups.";
    startAt = "hourly";
    environment = {
      inherit (config.environment.variables);
    };

    serviceConfig = {
      User = "root";
      ExecStart = "${pkgs.bash}/bin/bash -c 'date > /etc/.backup-tester'";
    };
  };

  systemd.services.backup-tester-dc = rec {
    description = "Create a file with the current time for use when checking backups.";
    startAt = "hourly";
    environment = {
      inherit (config.environment.variables);
    };

    serviceConfig = {
      User = "eldridge";
      ExecStart = "${pkgs.bash}/bin/bash -c 'date > /mnt/dc/.backup-tester'";
    };
  };

  systemd.services.restic-backups-home-remote = {
    environment = {
      B2_ACCOUNT_ID = (import ./secrets.nix).b2_account_id;
      B2_ACCOUNT_KEY = (import ./secrets.nix).b2_account_key;
    };
  };

  systemd.services.restic-backups-etc-remote = {
    environment = {
      B2_ACCOUNT_ID = (import ./secrets.nix).b2_account_id;
      B2_ACCOUNT_KEY = (import ./secrets.nix).b2_account_key;
    };
  };

  systemd.services.restic-backups-dc-remote = {
    environment = {
      B2_ACCOUNT_ID = (import ./secrets.nix).b2_account_id;
      B2_ACCOUNT_KEY = (import ./secrets.nix).b2_account_key;
    };
  };
}
