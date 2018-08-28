using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;

namespace MatlabEditor
{
    
    /// <summary>
    /// Implement a json sequence
    /// </summary>
    [JsonObject(MemberSerialization.OptOut)]
    public class Sequence
    {
        #region Members

        /// <summary>
        /// The properties associated with the sequence.
        /// </summary>
        [JsonProperty]
        public Dictionary<string,string> Parameters { get; set; }

        /// <summary>
        /// The code associated with the sequence.
        /// </summary>
        public string Code { get; private set; }

        #endregion

        #region Methods

        /// <summary>
        /// Convert the sequene into matlab code.
        /// </summary>
        /// <param name="paramObjectName"></param>
        /// <returns></returns>
        public string ToMatlabEvalCode(string paramObjectName)
        {
            StringBuilder builder = new StringBuilder();
            builder.Append(paramObjectName + "=struct;");
            builder.Append(String.Join(";\n", Parameters.Select((kvp) =>
            {
                return paramObjectName + ".('" + kvp.Key + "')=" + kvp.Value + ";\n";
            })));
            builder.Append("\n\n%Code here\n\n");
            builder.Append(Code);
            return builder.ToString();
        }

        #endregion

        #region Static members

        /// <summary>
        /// Loads a sequence from file.
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        public static Sequence FromFile(string path)
        {
            if (!System.IO.File.Exists(path))
                throw new Exception("File dose not exist.");

            string json = System.IO.File.ReadAllText(path);
            return Newtonsoft.Json.JsonConvert.DeserializeObject<Sequence>(json);
        }

        /// <summary>
        /// Saves a sqq
        /// </summary>
        /// <param name="path"></param>
        public void SaveToFile(string path)
        {
            string json = JsonConvert.SerializeObject(this, Formatting.Indented);
            System.IO.File.WriteAllText(path, json);
        }

        #endregion
    }
}
