#/bin/env sh
# Gets current screen based on mouse position
# Licensed under GPLv2
# requires xdotool, grep, head, xrandr, cut

# Bc they are declared as integers, even if xdotool doesn't set them they'll have the value 0
declare -i X
declare -i Y
declare -i SCREEN

eval "$(xdotool getmouselocation --shell | head -3)"

# Get the geometry of the screens
declare -A screen_sizes
declare -A screen_positions

# Greps the connected monitors of the screen given by xdotool
# Set IFS to loopt line by line rather than space by space
(
    IFS=$'\n'
    for xrandr_output in $(xrandr --screen $SCREEN | grep '\sconnected\s')
    do
        output="$(echo $xrandr_output | cut '-d ' -f1)"

        # Size
        tmp="$(echo $xrandr_output | grep -Po '\d+x\d+' | tr 'x' ' ')"

        # I Couldnt figure out zsh arrays so whatever
        op_size_x="$(cut '-d ' -f1 <<< $tmp)"
        op_size_y="$(cut '-d ' -f2 <<< $tmp)"

        # Offset
        tmp="$(echo $xrandr_output | grep -Po '(\+|-)\d+')"

        op_offset_x="$(head -1 <<< $tmp)"
        op_offset_y="$(tail -1 <<< $tmp)"

        # Check that cursor is inside the screen.
        # Width then height.
        if [ $op_offset_x -le $X -a $X -le $(($op_size_x + $op_offset_x)) ] &&\
           [ $op_offset_y -le $Y -a $Y -le $(($op_size_y + $op_offset_y)) ]
        then
            echo "$output"
            break;
        fi

    done
)
