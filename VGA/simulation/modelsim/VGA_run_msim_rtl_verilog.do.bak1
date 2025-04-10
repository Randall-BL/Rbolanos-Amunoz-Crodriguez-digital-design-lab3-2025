transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/vgaController.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/pll.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/videoGen.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/tic_tac_toe_fsm.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/toplevel_tic_tac_toe.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/startScreen.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/matrixTablero.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/matrixTableroControl.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/Button_debonce.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/Timer.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/Full_Timer.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/BCD_Visualizer.sv}
vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/gameOverScreen.sv}

vlog -sv -work work +incdir+C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA {C:/Users/tenor/OneDrive/Documentos/Lab1_TDD/jtenorio_aflores_klobo_digital_design_lab_2024/Laboratorio_3/VGA/toplevel_tic_tac_toe_tb.sv}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  tic_tac_toe_fsm_tb

add wave *
view structure
view signals
run -all
