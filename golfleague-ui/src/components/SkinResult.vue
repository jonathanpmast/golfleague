<template>
  <div class="overflow-hidden flex justify-center flex-col sm:justify-start max-w-md">
    <skin-winners
      :week-data="skinResultData"
      :show-header="false"
    />
    
    <table
      v-if="skinResultData && configData"
      class="table-auto border-collapse text-sm shadow-md rounded bg-white border-gray-200 mt-2"
    >
      <thead>
        <tr>
          <th class="border-b bg-gray-200" />
          <th class="text-center px-1 border">
            H
          </th>
          <th
            v-for="n in 9"
            :key="n"
            class="text-center px-1 border"
          >
            {{ skinResultData.startHole + n - 1 }}
          </th>
          <th class="text-center px-1 border">
            T
          </th>
        </tr>
        <tr>
          
          <th class="text-right px-1 border" colspan="2">
            Stroke Index
          </th>
          <th
            v-for="n in 9"
            :key="n"
            class="text-center px-1 border"
          >
            {{ configData.courseData.holes[skinResultData.startHole-2 +n].strokeIndex }}
            
          </th>
          <th class="text-center px-1 border">
            
          </th>
        </tr>
        <tr>
          
          <th class="text-right px-1 border" colspan="2">
            Par
          </th>
          <th
            v-for="n in 9"
            :key="n"
            class="text-center px-1 border bg-gray-50"
          >
            {{ configData.courseData.holes[skinResultData.startHole-2 +n].par }}
            
          </th>
          <th class="text-center px-1 border">
            
          </th>
        </tr>
      </thead>
      <tbody>
        <template
          v-for="(result,idx) in formattedSkinResultData"
          :key="idx"
        >
          <tr class="border-b">
            <td class="text-right text-sm px-1">
              <responsive-golfer-name
                :name="result.golferName"
                :short-name="result.golferShortName"
              />
            </td>
            <td class="text-center border-r text-xs bg-gray-50">
              {{ result.handicap }}
            </td>
            <td
              v-for="(hole, index) in result.holes"
              :key="index"
              class="text-center"
            >
              <div 
              
              :class="{'rounded-full border border-gray-500 h-5 w-5 ml-0.5':isGrossUnderPar(hole.gross,configData.courseData.holes[skinResultData.startHole-1+index].par)}"
              >
                {{ hole.gross }}
              </div>
            </td>
            <td class="border-l border-r px-2 text-center">
              {{ result.grossTotal }}
            </td>
          </tr>
          <tr class="border-b">
            <td
              colspan="2"
              class="text-right text-xs border-r bg-gray-200 pr-2"
            >
              Net
            </td>
            <td
              v-for="(hole, netIndex) in result.holes"
              :key="netIndex"
              class="text-center "
              :class="{'bg-green-200':hole.isSkin,'bg-red-200':hole.cancelSkin}"
            >
              {{ hole.net }}
            </td>
            <td class="border-l border-r px-2 text-center">
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
import ResponsiveGolferName from "../components/ResponsiveGolferName.vue"
import SkinWinners from "../components/SkinWinners.vue";
export default {
    name: "SkinResult",
    components: {
      ResponsiveGolferName,
      SkinWinners
    },
    props: {
        skinResultData: {
            type: Object,
            default() {
                return null;
            }
        },
        configData: {
          type: Object,
          default() {
            return null;
          }
        }
    },
    setup(props) {
        const {getGolferNames,formatDate} = useUtils(); 
        const isGrossUnderPar = (score,par) => {          
          return score < par;
        }
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
                    grossTotal:0,
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
            formattedSkinResultData,
            formatDate,
            isGrossUnderPar
        }
    },
}
</script>
