# stop git from trying to commit this file
# git update-index --assume-unchanged work.nu
#
# tell git to continue tracking this file as usual 
# git update-index --no-assume-unchanged work.nu



def maxmsp [maxpat: string = ""] {
    `C:\Program Files\Cycling '74\Max 8\Max.exe` ($maxpat | path expand)
}
