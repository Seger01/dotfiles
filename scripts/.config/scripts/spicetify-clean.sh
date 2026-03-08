rm -rf ~/.config/spicetify/Backup
rm -rf ~/.config/spicetify/Extracted

spicetify config spotify_path "$HOME/.local/share/spotify-launcher/install/usr/share/spotify"

spicetify backup apply
spicetify update
spicetify restore backup apply
