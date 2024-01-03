#!/bin/bash

# Check for all updates
updates=$(dnf check-update | grep -v kernel)
echo "*****************************************************************************"
# Check if there are any updates available
if [ -z "$updates" ]; then
    echo "No updates available."
else
    echo "Updates available:"
    echo "$updates"

     read -p "Do you want to install these updates? (y/n): " install_answer
    if [[ "$install_answer" == "y" ]]; then
        # Perform the updates
        dnf update --exclude=kernel*
        echo "Updates have been installed."
    else
        echo "Update installation cancelled."
    fi
fi
echo "*****************************************************************************"
    # Check for kernel updates
    kernel_updates=$(echo "$updates" | grep kernel)

    if [ -n "$kernel_updates" ]; then
        echo "Kernel updates available:"
        echo "$kernel_updates"

        # Ask user if they want to update the kernel
        read -p "Do you want to update the kernel? (y/n): " answer
        if [[ "$answer" == "y" ]]; then
            # Update the kernel
            dnf update kernel

            # Ask if the user wants to reboot after kernel update
            read -p "Kernel update complete. Do you want to reboot now? (yes/no): " reboot_answer
            if [[ "$reboot_answer" == "yes" ]]; then
                echo "Rebooting the system!"
                reboot
            else
                echo "Reboot cancelled. Remember to reboot later to apply kernel updates."
            fi
        else
            echo "Kernel update cancelled."
        fi
    else
        echo "No kernel updates available."
    fi
echo "*****************************************************************************"