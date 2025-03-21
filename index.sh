<style>
    * {
        background-color: #352e2e;
        font-family: monospace;
        color: rgb(60, 255, 1);
        padding: 0px;
    }

    button,
    datalist {
        background-color: rgb(85, 85, 85);
    }

    input[type=text] {
        color: rgb(179, 255, 179);
        background-color: rgb(102, 86, 86);
        border: 1px solid;
        border-color: #696 #363 #363 #696;
    }

    #serialResults {
        font-family: monospace;
        white-space: pre;
        height: calc(100% - 120px);
        width: calc(100% - 20px);
        border-style: solid;
        overflow: scroll;
        background-color: rgb(88, 92, 92);
        padding: 10px;
        margin: 0px;
    }
</style>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Fastest Serial terminal in your browser for Chrome.</title>
<meta name="Description" content="Set your baud speed and hit connect.
 A serial terminal that runs with out any plugins in chrome.">

<button onclick="connectSerial()">Connect</button>
Baud:
<input type="text" id="baud" list="baudList" style="width: 10ch;" onclick="this.value = ''"
    onchange="localStorage.baud = this.value">
<datalist id="baudList">
    <option value="110">110</option>
    <option value="300">300</option>
    <option value="600">600</option>
    <option value="1200">1200</option>
    <option value="2400">2400</option>
    <option value="4800">4800</option>
    <option value="9600">9600</option>
    <option value="14400">14400</option>
    <option value="19200">19200</option>
    <option value="38400">38400</option>
    <option value="57600">57600</option>
    <option value="115200">115200</option>
    <option value="128000">128000</option>
    <option value="256000">256000</option>
</datalist>
<button onclick="serialResultsDiv.innerHTML = '';">Clear</button>

<br>
<input type="text" id="lineToSend" style="width:calc(100% - 165px)">
<button onclick="sendSerialLine()" style="width:45px">Send</button>
<button onclick="sendCharacterNumber()" style="width:100px">Send Char</button>
<br>

<input type="checkbox" id="addLine" onclick="localStorage.addLine = this.checked;" checked>
<label for="addLine">send with /r/n</label>

<input type="checkbox" id="echoOn" onclick="localStorage.echoOn = this.checked;" checked>
<label for="echoOn">echo</label>


<br>
<div id="serialResults">
</div>
<script>
    var port, textEncoder, writableStreamClosed, writer;
    async function connectSerial() {
        try {
            // Prompt user to select any serial port.
            port = await navigator.serial.requestPort();
            await port.open({ baudRate: document.getElementById("baud").value });

            textEncoder = new TextEncoderStream();
            writableStreamClosed = textEncoder.readable.pipeTo(port.writable);

            writer = textEncoder.writable.getWriter();
            listenToPort();
        } catch {
            alert("Serial Connection Failed");
        }
    }
    async function sendCharacterNumber() {
        document.getElementById("lineToSend").value = String.fromCharCode(document.getElementById("lineToSend").value);
    }
    async function sendSerialLine() {
        dataToSend = document.getElementById("lineToSend").value;
        if (document.getElementById("addLine").checked == true) dataToSend = dataToSend + "\r\n";
        if (document.getElementById("echoOn").checked == true) appendToTerminal("> " + dataToSend);
        await writer.write(dataToSend);
    }
    async function listenToPort() {
        const textDecoder = new TextDecoderStream();
        const readableStreamClosed = port.readable.pipeTo(textDecoder.writable);
        const reader = textDecoder.readable.getReader();
        // Listen to data coming from the serial device.
        while (true) {
            const { value, done } = await reader.read();
            if (done) {
                // Allow the serial port to be closed later.
                reader.releaseLock();
                break;
            }
            // value is a string.
            appendToTerminal(value);
        }
    }
    const serialResultsDiv = document.getElementById("serialResults");
    async function appendToTerminal(newStuff) {
        serialResultsDiv.innerHTML += newStuff;
        if (serialResultsDiv.innerHTML.length > 3000) serialResultsDiv.innerHTML = serialResultsDiv.innerHTML.slice(serialResultsDiv.innerHTML.length - 3000);

        //scroll down to bottom of div
        serialResultsDiv.scrollTop = serialResultsDiv.scrollHeight;
    }
    document.getElementById("lineToSend").addEventListener("keyup", async function (event) {
        if (event.keyCode === 13) {
            sendSerialLine();
        }
    })
    document.getElementById("baud").value = (localStorage.baud == undefined ? 9600 : localStorage.baud);
    document.getElementById("addLine").checked = (localStorage.addLine == "false" ? false : true);
    document.getElementById("echoOn").checked = (localStorage.echoOn == "false" ? false : true);
</script>
<br> © 2021 Mike Molinari (mmiscool) Source <a
    href="https://github.com/mmiscool/serialTerminal.com">https://github.com/mmiscool/serialTerminal.com</a>
