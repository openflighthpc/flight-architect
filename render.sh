# Variables
PLATFORM=$1
case $PLATFORM in 
  aws|azure)
    ;;
  *)
    echo "Invalid platform '$PLATFORM', please follow this script with aws or azure"
    exit 1
esac

CONTENTBASE=/root/mountain-climber-wip/underware/data/templates/content
INPUTBASE=/root/mountain-climber-wip/underware/data/templates/$PLATFORM
OUTPUTBASE=/var/lib/underware/rendered/$PLATFORM

# Functions
strip_input_path() {
    echo $1 |sed "s,$2,,g"
}

run_in_scope() {
    SCOPEIN=$INPUTBASE/$1
    if [ ! -z "$2" ] ; then
        SCOPEOUT=$OUTPUTBASE/$1/$2
    else
        SCOPEOUT=$OUTPUTBASE/$1
    fi

    # Platform Scripts
    for file in $(find $SCOPEIN/*) ; do
        echo mkdir -p $SCOPEOUT/$(dirname $(strip_input_path "$file" "$SCOPEIN"))
        echo underware render $file $2 \> $SCOPEOUT/$(strip_input_path "$file" "$SCOPEIN")
    done

    # Content Scripts
    for file in $(find $CONTENTBASE/$1/*) ; do
        echo mkdir -p $SCOPEOUT/$(dirname $(strip_input_path "$file" "$CONTENTBASE/$1"))
        echo underware render $file $2 \> $SCOPEOUT/$(strip_input_path "$file" "$CONTENTBASE/$1")
    done

}

# Domain
run_in_scope domain

# Group
#for group in $(underware eval 'groups.each do |group| puts group.name end; nil' | sed '$d') ; do
#    run_in_scope group $group
#done

# Node
for node in $(underware eval 'nodes.each do |node| puts node.name end ; nil' |sed '$d') ; do
    run_in_scope node $node
done
