"""
Run this script to update all mod support related files.
Read more about automated mod support here:
https://github.com/Ceterai/Enternia/wiki/Modding-Mod-Support
"""

import mods.RT
import mods.FU
import mods.IFD
import mods.MPI
import mods.EES
import mods.WI
import mods.SIP
import mods.RB

def run():
    # Runs all support scripts and returns their affected files in one list.
    return (
        mods.RT.run() +
        mods.FU.run() +
        mods.IFD.run() +
        mods.MPI.run() +
        mods.EES.run() +
        mods.WI.run() +
        mods.SIP.run() +
        mods.RB.run()
    )
