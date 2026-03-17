#
# PackageMaker - a GAP script for creating GAP packages
#
# Copyright (c) 2013-2019 Max Horn
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#

BindGlobal( "DISABLED_ENTRY", MakeImmutable("DISABLED_ENTRY") );

BindGlobal( "PKGMKR_RunCommand", function( dir, cmd, args, instream, outstream )
    local path, cmd_full, close_instream, res;

    close_instream := false;
    if instream = fail then
        instream := InputTextNone();
        close_instream := true;
    fi;

    path := DirectoriesSystemPrograms();
    cmd_full := Filename( path, cmd );
    if cmd_full = fail then
        if close_instream then
            CloseStream( instream );
        fi;
        return fail;
    fi;

    res := Process( dir, cmd_full, instream, outstream, args );
    if close_instream then
        CloseStream( instream );
    fi;
    return res;
end );

BindGlobal( "PKGMKR_CommandOutput", function( dir, cmd, args )
    local out, outstream, instream, res;

    out := "";
    outstream := OutputTextString( out, false );
    instream := InputTextString( "" );
    res := PKGMKR_RunCommand( dir, cmd, args, instream, outstream );
    CloseStream( instream );
    CloseStream( outstream );

    if res <> 0 then
        return fail;
    fi;
    return out;
end );

# Return current date as a string with format DD/MM/YYYY.
BindGlobal( "Today", function()
    local secs, tmp, date;
    tmp := IO_gettimeofday();
    secs := tmp.tv_sec;

    date := DMYDay(Int(secs / 86400));
    date := date + [100, 100, 0];
    date := List( date, String );
    date := Concatenation( date[1]{[2,3]}, "/", date[2]{[2,3]}, "/", date[3] );

    return date;
end );

InstallGlobalFunction( PackageWizard, function()
    local answers;

    answers := PackageWizardInput();
    if answers = fail then
        return;
    fi;
    PackageWizardGenerate( answers );
end );
