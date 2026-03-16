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

BindGlobal( "Command", function(cmd, args)
    local out, outstream, instream, path, cmd_full, res;

    out := "";
    outstream := OutputTextString(out, false);
    instream := InputTextString("");

    path := DirectoriesSystemPrograms();
    cmd_full := Filename( path, cmd );
    if cmd_full = fail then
        CloseStream(instream);
        CloseStream(outstream);
        #Error("Could not locate command '", cmd, "' in your PATH");
        return fail;
    fi;

    res := Process(DirectoryCurrent(), cmd_full, instream, outstream, args);

    CloseStream(instream);
    CloseStream(outstream);

    if res = 0 then
        return out;
    fi;
    return fail;
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

    Print("Welcome to the GAP PackageMaker Wizard.\n",
          "I will now guide you step-by-step through the package\n",
          "creation process by asking you some questions.\n\n");

    answers := PackageWizardInput();
    if answers = fail then
        return;
    fi;
    PackageWizardGenerate( answers );
end );
