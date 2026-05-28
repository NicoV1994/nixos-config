{
  networking.hosts = {
    "127.0.0.1" = [
      "www.carenext.test"
      "carenext.test"
      "www.carenext.local"
      "carenext.local"
      "login.carenext.test"
      "socket.carenext.test"
      "docs.carenext.test"
    ];
  };

  networking.firewall.trustedInterfaces = [
    "docker0"
    # Current Docker Compose bridge for /home/nico/Haggla/Milon/milon-care-next.
    "br-f078f06683cb"
  ];
}
