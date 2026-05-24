# -*- coding: utf-8 -*-
"""GBK .asv -> UTF-8 .m, re-apply bugfixes. No Chinese literals in this file."""
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def read_gbk(name: str) -> str:
    return (ROOT / name).read_bytes().decode("gbk").replace("\r\n", "\n")


def fix_drivecode():
    # Boundaries for moving Step-4 completion lines must be computed AFTER all
    # replacements; otherwise offsets from the original .asv slice mid-string.
    t = read_gbk("DriveCode.asv")
    i0 = t.find(
        "DAF50=1/(sqrt((1-1/(Tm50*f_fb_target)^2)^2+(2*0.05*1/(Tm50*f_fb_target))));"
    )
    nl = t.find("\n", i0)
    daf50_line = t[i0 : nl + 1]
    insert = (
        daf50_line
        + "% Hs2 (3rd wave for Hydro_load_1and50yrs); default 1.07 per inputdata.dat\n"
        + "Hs2=1.07;\n"
        + "Ts2=11.1*sqrt(Hs2/g);\n"
        + "N2=3600/(Ts2);\n"
        + "Hm2=Hs2*sqrt(log(N2)/2);\n"
        + "Tm2=11.1*sqrt(Hm2/g);\n"
        + "DAF2=1/(sqrt((1-1/(Tm2*f_fb_target)^2)^2+(2*0.05*1/(Tm2*f_fb_target))));\n"
    )
    t = t.replace(daf50_line, insert, 1)

    t = t.replace("for i = 3:3", "for i = 1:Num_floor")
    t = t.replace("if size(Ftx_1y)~=size(t)", "if numel(Ftx_1y)~=numel(t)")
    t = t.replace("if size(Ftx_50y)~=size(t)", "if numel(Ftx_50y)~=numel(t)")
    t = t.replace(
        "W_jk=Weight_jacket(Num_bar,steel_density,Hydro.density);",
        "W_jk=Weight_jacket(Num_bar_array,steel_density,Hydro.density,Y0_position(i));",
    )
    t = t.replace(
        "W_jk=Weight_jacket(Num_bar,steel_density, Hydro.density);",
        "W_jk=Weight_jacket(Num_bar_array,steel_density, Hydro.density,Y0_position(i));",
    )
    t = t.replace(
        "[F1,M1,F50,M50]=Hydro_load_1and50yrs(Hm50, Tm50, DAF50, Hm1, Tm1, DAF1,",
        "[F1,M1,F50,M50,~,~]=Hydro_load_1and50yrs(Hm2, Tm2, DAF2, Hm50, Tm50, DAF50, Hm1, Tm1, DAF1,",
    )
    t = t.replace(
        "Diameter_thickness_ini(i,LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);",
        "Diameter_thickness_update(i,LegidPfloor, BraceidPfloor, D_leg, D_brace, t_leg, t_brace);",
    )
    t = t.replace("if i==4", "if i==Num_floor")

    _bad_leg = (
        "    fprintf('"
        + "\u5b8c\u6210leg\u548cbrace\u6297\u538b\u627f\u8f7d\u529b\u8bbe\u8ba1\u503c\u8ba1\u7b97"
        + "\":\\n');"
    )
    _good_leg = (
        "    fprintf('"
        + "\u5b8c\u6210leg\u548cbrace\u6297\u538b\u627f\u8f7d\u529b\u8bbe\u8ba1\u503c\u8ba1\u7b97"
        + ";\\n');"
    )
    t = t.replace(_bad_leg, _good_leg)

    step5_marker = (
        "\n    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n    % Step 5:"
    )
    idx_m = t.find("M_50y_all(i)=DAF50*Mtz_50y_max;\n")
    if idx_m < 0:
        raise SystemExit("DriveCode: M_50y_all line not found")
    a = idx_m + len("M_50y_all(i)=DAF50*Mtz_50y_max;\n")
    b = t.find(step5_marker, a)
    if b < 0:
        raise SystemExit("DriveCode: Step 5 marker not found after M_50y_all")
    step4_done_block = t[a:b]
    t = t[:a] + t[b:]

    mi = t.find("end %20240624")
    if mi < 0:
        raise SystemExit("DriveCode: end marker not found")
    mi_end = t.find("\n", mi)
    if mi_end < 0:
        mi_end = len(t)
    else:
        mi_end += 1
    t = t[:mi_end] + step4_done_block + "\n" + t[mi_end:]

    old9 = (
        "[Ftx_1y_wav,Fty_1y_wav,Ftz_1y_wav,Mtx_1y_wav,Mtz_1y_wav,F_bracex_1y_wav,"
        "M_bracez_1y_wav,t]=Hydro_load_timehistory(t0,t1,dt,Num_bar);"
    )
    new9 = (
        "Num_bar_array_uls=get_bar_array_for_floor(Num_floor,LegidPfloor,BraceidPfloor);\n"
        "y0_uls=Y0_position(Num_floor);\n"
        "[Ftx_1y_wav,Fty_1y_wav,Ftz_1y_wav,Mtx_1y_wav,Mtz_1y_wav,t]="
        "Hydro_load_timehistory(t0,t1,dt,Num_bar_array_uls,y0_uls);"
    )
    if old9 not in t:
        raise SystemExit("DriveCode: Step9 Hydro_load_timehistory not found")
    t = t.replace(old9, new9)

    _drivecode_files = (
        "projRoot = fileparts(mfilename('fullpath'));\n"
        "DriveCode = struct( ...\n"
        "    'inputdataFile', fullfile(projRoot, 'inputdata.dat'), ...\n"
        "    'elementsDat', fullfile(projRoot, 'jacket_elements.dat'), ...\n"
        "    'nodesDat', fullfile(projRoot, 'node_coordinates.dat') ...\n"
        "    );\n"
        "% Optional: inp = readData(DriveCode.inputdataFile);\n"
        "\n"
    )
    if "DriveCode = struct" not in t:
        t = t.replace("clc;\nclear all;\n", "clc;\nclear all;\n" + _drivecode_files, 1)

    _step9_done = (
        "fprintf('"
        + "\u0022Step 9: \u6821\u6838\u5854\u9876\u4f4d\u79fb\u0022\u5df2\u5b8c\u6210;\\n\\n');\n"
    )
    _step10 = (
        "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
        "% Step 10: \u5bfc\u51fa\u6746\u4ef6\u8868\u3001\u8282\u70b9\u8868\u5e76\u7ed8\u5236 Member "
        "\u51e0\u4f55\uff08ganjian / jiedian / cord_Cal\uff09\n"
        "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n"
        "fprintf('\u7a0b\u5e8f\u8fdb\u5165\u0022Step 10: "
        "\u5bfc\u51fa\u51e0\u4f55\u4e0e\u7ed8\u56fe\u0022:\\n');\n"
        "ganjian(DriveCode.elementsDat, Num_bar);\n"
        "jiedian(DriveCode.nodesDat, Num_bar);\n"
        "cord_Cal(Num_bar);\n"
        "fprintf('\u0022Step 10: \u5bfc\u51fa\u51e0\u4f55\u4e0e\u7ed8\u56fe\u0022\u5df2\u5b8c\u6210;\\n\\n');\n"
    )
    if "ganjian(DriveCode.elementsDat" not in t and _step9_done in t:
        t = t.replace(_step9_done, _step9_done + _step10, 1)

    fp = ROOT / "DriveCode.m"
    fp.write_text(t, encoding="utf-8", newline="\n")
    t2 = fp.read_text(encoding="utf-8")
    anchor = "end %20240624"
    k = t2.find(anchor)
    if k >= 0:
        k = t2.find("\n", k)
        if k < 0:
            k = len(t2)
        else:
            k += 1
        if t2.startswith("    ", k):
            t2 = t2[:k] + t2[k + 4 :]
        needle = "fprintf('" + "\u5b8c\u6210\u91cd\u73b0\u5468\u671f1\u5e74\u300150\u5e74\u6ce2\u6d6a\u8377\u8f7d\u8ba1\u7b97;"
        j = t2.find(needle)
        if j >= 0:
            j = t2.find("\n", j) + 1
            if t2.startswith("    ", j):
                t2 = t2[:j] + t2[j + 4 :]
    fp.write_text(t2, encoding="utf-8", newline="\n")
    print("OK DriveCode.m utf-8")


def fix_hydro():
    t = read_gbk("Hydro_load_1and50yrs.asv")
    merged_ok = False
    for line in t.split("\n"):
        if "Wave.h=Hm2" in line and "Wave.k=wave_number" in line:
            p = line.find("Wave.k=wave_number")
            t = t.replace(line, line[:p] + "\n" + line[p:], 1)
            merged_ok = True
            break
    if not merged_ok:
        raise SystemExit("Hydro: merged Wave line not found")

    t = t.replace(
        "    if Member_group<0\n",
        "    if any(Member_group(:)<0)\n",
    )
    (ROOT / "Hydro_load_1and50yrs.m").write_text(t, encoding="utf-8", newline="\n")
    print("OK Hydro_load_1and50yrs.m utf-8")


def fix_weight_jacket():
    w = """function [Wg] = Weight_jacket(Num_bar_array, steel_density, water_density,y0)
% Effective jacket weight above y0 for members in Num_bar_array (buoyancy considered).
% Inputs: member IDs, steel_density, water_density, y0 (m).
global Member;
global Wave;
Wg = 0;
for i = 1:length(Num_bar_array)
    index = Num_bar_array(i);
    if index > length(Member.L)
        error('Member index out of range');
    end
    if Member.Yt(index)<y0
        w = 0;
    else
        if Member.Yt(index) <= Wave.S
            w = Member.L(index) * 0.25 * pi * ((Member.D(index))^2 - (Member.D(index) - 2 * Member.t(index))^2) * (steel_density - water_density) * 9.8;
        elseif Member.Y0(index) >= Wave.S
            w = Member.L(index) * 0.25 * pi * ((Member.D(index))^2 - (Member.D(index) - 2 * Member.t(index))^2) * steel_density * 9.8;
        else
            w = Member.L(index) * (Wave.S - Member.Y0(index)) / (Member.Yt(index) - Member.Y0(index)) * 0.25 * pi * ((Member.D(index))^2 - (Member.D(index) - 2 * Member.t(index))^2) * (steel_density - water_density) * 9.8 + ...
                Member.L(index) * (Member.Yt(index) - Wave.S) / (Member.Yt(index) - Member.Y0(index)) * 0.25 * pi * ((Member.D(index))^2 - (Member.D(index) - 2 * Member.t(index))^2) * steel_density * 9.8;
        end
    end
    Wg = Wg + w;
end
end
"""
    (ROOT / "Weight_jacket.m").write_text(w, encoding="utf-8", newline="\n")
    print("OK Weight_jacket.m utf-8")


def fix_geometry_jacket():
    path = ROOT / "Geometry_jacket.m"
    raw = path.read_bytes()
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError:
        text = raw.decode("gbk")
    text = text.replace("\r\n", "\n")
    parts = text.split("elseif Num_floor==3", 1)
    if len(parts) == 2:
        block = parts[1]
        if "h2=h3/m" not in block[:800]:
            idx = block.find("h3=h4/m;")
            if idx != -1:
                insert_at = idx + len("h3=h4/m;")
                block = block[:insert_at] + "\n    h2=h3/m;\n" + block[insert_at:].lstrip("\n")
                text = parts[0] + "elseif Num_floor==3" + block
    path.write_text(text, encoding="utf-8", newline="\n")
    print("OK Geometry_jacket.m utf-8")


if __name__ == "__main__":
    fix_drivecode()
    fix_hydro()
    fix_weight_jacket()
    fix_geometry_jacket()
