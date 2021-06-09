export default function useUtils() {
    function getGolferNames(golferName) {
        var formattedGolferName = "";
        var golferShortName = "";
        var split = golferName.split(',');
        if(split.length === 1) {
            formattedGolferName = golferShortName = golferName
        }
        else {
            let name = `${golferName.split(',')[1].trim()} ${golferName.split(',')[0].trim()}`;
            formattedGolferName= name;
            golferShortName =  name.split(' ')[0][0] +" "+ name.split(' ')[1]  
        }
        return {
            formattedGolferName,
            golferShortName
        }

    }
    return {
        getGolferNames
    }
}