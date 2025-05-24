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
find . -maxdepth 1 -type l | while read -r link; do
    # Get the target path
    target=$(readlink "$link")

    # Create backup of original symlink
    #cp -P "$link" "${link}.bak"

    # Replace the text in the target path
    new_target=${target//theme/$chosenTheme}

    # Remove old symlink and create new one
    unlink "$link"
    ln -s "$new_target" "$(basename "$link")"

    echo "Processed symlink: $link"
done
rm folder-root.svg
ln -s folder-$chosenTheme-private.svg folder-root.svg
}

install_config() {
choose_theme
# Test if necessary packages are installed
if [ ! -e /usr/bin/git ] || [ ! -e /usr/bin/papirus-folders ] || [ ! -e /usr/bin/zsh ] || [ ! -e /usr/bin/fish ] || [ ! -d /usr/share/icons/Papirus ] || [ ! -e /usr/bin/starship ] || [ ! -e /usr/bin/fastfetch ] || [ ! -e /usr/bin/fzf ] || [ ! -e /usr/bin/eza ]; then
echo "Some needed packages are not installed. Please install papirus-icon-theme, papirus-folder, fish, zsh, starship, fastfetch, fzf and eza then try again"; exit
fi;
echo "Copying files..." &&
cp -rfv ./$chosenTheme/config/* ~/.config/ &&
cp -rfv ./$chosenTheme/local/share/* ~/.local/share/ &&
cp -rfv ./$chosenTheme/zsh/.zshrc ~/.zshrc &&
mkdir -pv ~/.local/share/fonts &&
sudo cp -rfv ./fonts/* /usr/share/fonts &&
sudo cp -rfv ./polaris-folders/* /usr/share/icons/Papirus &&
echo "Running omz installation script"
./$chosenTheme/zsh/installohmyzsh.sh;
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
cp $chosenTheme/zsh/.zshrc ~/.zshrc
echo "Applying colour theme to icons" &&
cd polaris-folders/ &&
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
echo "All done. Now, head over to the Plasma settings and apply the theme colours, and the Papirus-Dark icon pack. Then, read the widget instructions and apply the theme there as well. Finally, go to your theme's 'zsh' folder and run the 'ohmyzsh.sh' and 'post-install.sh' scripts, in that order. Enjoy!"
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


