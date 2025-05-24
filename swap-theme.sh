#!/bin/bash

choose_theme() {
read -p "Which theme would you like to install? (oddfish/moonflowers/lachesis/upas) " choiceTheme
case "$choiceTheme" in
  oddfish ) chosenTheme=oddfish;;
  moonflowers ) chosenTheme=moonflowers;;
  lachesis ) chosenTheme=lachesis;;
  upas ) chosenTheme=upas;;
  * ) echo "Please enter a valid theme name."; exit;;
esac
}

symlink_fix() {
# Find all symlinks and process them
#find . -maxdepth 1 -type l | while read -r link; do
    # Get the target path
    #target=$(readlink "$link")

    # Create backup of original symlink
    #cp -P "$link" "${link}.bak"

    # Replace the text in the target path
    #new_target=${target//theme/$chosenTheme}

    # Remove old symlink and create new one
    #unlink "$link"
    #ln -s "$new_target" "$(basename "$link")"

    #echo "Processed symlink: $link"
#done
sudo rm folder-root.svg &&
sudo ln -s folder-$chosenTheme-private.svg folder-root.svg
}

install_config() {
choose_theme
echo "Copying files..." &&
rm -rf ~/.config/{fastfetch,fish,kdeglobals,konsolerc,plasma-org.kde.plasma.desktop-appletsrc,starship.toml,Trolltech.conf}
cp -rfv ./$chosenTheme/config/{fastfetch,fish,kdeglobals,konsolerc,plasma-org.kde.plasma.desktop-appletsrc,starship.toml,Trolltech.conf} ~/.config/ &&
rm -rf ~/.local/share/{applications,color-schemes,konsole,theme-icons,wallpapers}
cp -rfv ./$chosenTheme/local/share/{applications,color-schemes,konsole,theme-icons,wallpapers} ~/.local/share/ &&
cp -rfv ./$chosenTheme/zsh/.zshrc ~/.zshrc &&
echo "Applying colour theme to icons" &&
cd /usr/share/icons/Papirus/ &&
cd './22x22/places' &&
symlink_fix &&
cd '../../24x24/places' &&
symlink_fix &&
cd '../../32x32/places' &&
symlink_fix &&
cd '../../48x48/places' &&
symlink_fix &&
cd '../../64x64/places' &&
symlink_fix &&
echo "Setting Papirus folder icon colours" &&
papirus-folders -t Papirus-Dark -C $chosenTheme &&
echo "All done. Now, head over to the Plasma settings and apply the theme colours, and the Papirus-Dark icon pack. Then, read the widget instructions and apply the theme there as well. Enjoy!"
}

# Start by backing up the current .config and .local/share directories, if they exist and the user wishes to do so
read -p "Do you want to back up your .config and .local/share files? (might take a minute, recommended) (y/n)? " choice
case "$choice" in
  y|Y|yes ) if [ -d ~/.config ] && [ -d ~/.local/share ]; then
        tar -czvf ~/polaris-backup.tar.gz ~/.config ~/.local/share
    elif
        [ -d ~/.config ] && [ ! -d ~/.local/share ]; then
        echo "no ~/.local/share found, proceeding with ~/.config backup"
        tar -czvf ~/polaris-backup.tar.gz ~/.config
    elif
        [ -d ~/.local/share ] && [ ! -d ~/.config ]; then
        echo "no ~/.config found, proceeding with ~/.local/share backup"
        tar -czvf ~/polaris-backup.tar.gz ~/.local/share
    elif
        [ ! -d ~/.local/share ] && [ ! -d ~/.config ]; then
        echo "No .config or .local/share found"
    else
        echo "Unknown error when backing up, exiting..."
        exit
    fi;
    install_config;;
  n|N|no ) install_config;;
  * ) echo "Please answer y or n";;
esac
