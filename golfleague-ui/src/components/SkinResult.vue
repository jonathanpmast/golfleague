<template>
  <div class="mt-4 p-2 mb-3 rounded bg-white border-gray-200 shadow-md overflow-hidden">
    <table
      v-if="skinResultData"
      class="table-auto border-collapse text-sm"
    >
      <thead>
        <tr class="border-b">
          <th />
          <th class="text-center px-1">
            H
          </th>
          <th
            v-for="n in 9"
            :key="n"
            class="text-center px-1"
          >
            {{ skinResultData.startHole + n - 1 }}
          </th>
          <th class="text-center px-1">
            T
          </th>
        </tr>
      </thead>
      <tbody>
        <template
          v-for="(result,idx) in formattedSkinResultData"
          :key="idx"
        >
          <tr>
            <td class="text-right">
              {{ result.golferName }}
            </td>
            <td class="text-center border-r text-xs">
              {{ result.handicap }}
            </td>
            <td
              v-for="(hole, index) in result.holes"
              :key="index"
              class="text-center"
            >
              {{ hole.gross }}
            </td>
            <td class="border-l px-2">
              {{ result.grossTotal }}
            </td>
          </tr>
          <tr class="border-b">
            <td class="text-right bg-gray-200">
              NET
            </td>
            <td class="border-r" />
            <td
              v-for="(hole, netIndex) in result.holes"
              :key="netIndex"
              class="text-center "
              :class="{'bg-green-200':hole.isSkin,'bg-red-200':hole.cancelSkin}"
            >
              {{ hole.net }}
            </td>
            <td class="border-l px-2">
              {{ result.netTotal }}
            </td>
          </tr>
        </template>
      </tbody>
    </table>
  </div>
</template>
<script>
import {computed} from "vue";
import useUtils from "../common/useUtils";
export default {
    name: "SkinResult",
    props: {
        skinResultData: {
            type: Object,
            default() {
                return null;
            }
        }
    },
    setup(props) {
        const {getGolferNames} = useUtils(); 
        const formattedSkinResultData = computed(() => {
            if(!props.skinResultData)
                return null;
            console.log(props.skinResultData);
            let vm = [];
            for(let i = 0; i < props.skinResultData.results.length; i++) {
                let result = props.skinResultData.results[i];
                
                const {formattedGolferName, golferShortName} = getGolferNames(result.golferName);
                let golferData = {
                    golferName: formattedGolferName,
                    golferShortName: golferShortName,
                    handicap: result.handicap,
                    holes: [],
                    netTotal: 0,
                    grossTotal:0
                };
                for(let j = 0; j < result.holes.length; j++) {
                    let holeData = result.holes[j]
                    golferData.netTotal += holeData.net;
                    golferData.grossTotal += holeData.gross;
                    golferData.holes.push(holeData);
                }
                vm.push(golferData);
            }
            return vm;
        });

        return {
            formattedSkinResultData
        }
    },
}
</script>
