#!/bin/bash

echo "🚀 DEPLOYING COMPLETE MCP + A2A ENHANCED AI MONITORING SYSTEM"
echo "=============================================================="
echo ""

# Check if all script files exist
scripts=("script_1_setup.sh" "script_2_backend_core.sh" "script_3_agents.sh" "script_4_helpers_api.sh" "script_5_dashboard_websocket.sh" "script_6_frontend.sh" "script_7_build_launch.sh")

for script in "${scripts[@]}"; do
    if [[ ! -f "$script" ]]; then
        echo "❌ Error: $script not found!"
        echo "Please ensure all script files are present in the current directory."
        exit 1
    fi
    chmod +x "$script"
done

echo "✅ All script files found and made executable"
echo ""

# Run all scripts in sequence
echo "🔄 Running deployment sequence..."
for i in {1..6}; do
    script="script_${i}_*.sh"
    echo ""
    echo "🚀 Running Script $i..."
    ./script_${i}_*.sh
    
    if [[ $? -ne 0 ]]; then
        echo "❌ Script $i failed! Stopping deployment."
        exit 1
    fi
    
    echo "✅ Script $i completed successfully"
done

echo ""
echo "🎉 DEPLOYMENT SEQUENCE COMPLETED!"
echo "Now running final build and launch..."
./script_7_build_launch.sh
