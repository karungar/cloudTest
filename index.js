
        // Function to fetch and display resume data
        async function displayResume() {
            try {
                // Fetch the JSON data
                const response = await fetch('https://5q5rkjfar2adf66frm5p3nnioi0taxfd.lambda-url.us-west-2.on.aws/');
                const data = await response.json();

                // Destructure the data
                const { name, location, email, phone, profile, experience, education, skills, certifications, languages } = data;

                // HTML structure
                
                // Append each experience
                experience.forEach(exp => {
                    htmlContent += `
                    <div class="">
                        <div class="flex justify-between items-center">
                            <div class="">
                                <h2 class="text-2xl mb-1 font-medium text-gray-800">${exp.company}</h2>
                                <p class="text-xl italic mb-2 font-light text-gray-900">${exp.role}</p>
                            </div>
                            <div class="my-3">
                                <p class="text-md font-light text-gray-800 italic">
                                    <span class="text-violet-800">${exp.startDate} - ${exp.endDate}</span> <br>${exp.location}
                                </p>
                            </div>
                        </div>
                        <ul class="list-disc ml-4 marker:text-violet-500">`;
                    exp.tasks.forEach(task => {
                        htmlContent += `<li class="text-gray-900 font-light text-lg">${task}</li>`;
                    });
                    htmlContent += `</ul>
                    </div>`;
                });

                htmlContent += `</section>
                <!-- Education -->
                <section class="bg-white px-8 py-4">
                    <h2 class="text-2xl mb-3 font-bold uppercase text-gray-900">
                        <i class="fa-solid fa-graduation-cap"></i> Education
                        <hr class="bg-violet-800 h-1.5 mt-1 w-[50px]">
                    </h2>`;

                // Append each education
                education.forEach(edu => {
                    htmlContent += `
                    <div class="flex mb-4 justify-between">
                        <div class="">
                            <h2 class="text-lg mb-1 font-medium text-gray-800">${edu.degree}</h2>
                            <p class="font-light text-md italic text-gray-900">${edu.institution}</p>
                        </div>
                        <p class="text-md font-light text-gray-800 italic">
                            <span class="text-violet-800">${edu.startDate} - ${edu.endDate}</span> <br>${edu.location}
                        </p>
                    </div>`;
                });

                htmlContent += `</section>
                <!-- Skills -->
                <section class="bg-white px-8 py-4">
                    <h2 class="text-2xl mb-4 font-bold uppercase text-gray-900">
                        <i class="fa-solid fa-gears"></i> Skills
                        <hr class="bg-violet-800 h-1.5 mt-1 w-[50px]">
                    </h2>
                    <ul class="grid grid-cols-2 gap-2 list-disc list-inside marker:text-violet-500">`;

                // Append each skill
                skills.forEach(skill => {
                    htmlContent += `<li class="border-2 border-violet-50 text-lg font-light text-slate-900 p-2 rounded-lg">${skill}</li>`;
                });

                htmlContent += `</ul>
                </section>
                <!-- Certifications -->
                <section class="bg-white px-8 py-4">
                    <h2 class="text-2xl mb-4 font-bold uppercase text-gray-900">
                        <i class="fa-solid fa-gears"></i> Certifications
                        <hr class="bg-violet-800 h-1.5 mt-1 w-[50px]">
                    </h2>`;

                // Append each certification
                certifications.forEach(cert => {
                    htmlContent += `<p class="font-light text-md italic text-gray-900"><a href="${cert.url}">${cert.name}</a></p>`;
                });

                htmlContent += `</section>
                <!-- Languages -->
                <section class="bg-white px-8 py-4">
                    <h2 class="text-2xl mb-4 font-bold uppercase text-gray-900">
                        <i class="fa-solid fa-gears"></i> Languages
                        <hr class="bg-violet-800 h-1.5 mt-1 w-[50px]">
                    </h2>
                    <ul class="grid grid-cols-2 gap-2 list-disc list-inside marker:text-violet-500">`;

                // Append each language
                languages.forEach(language => {
                    htmlContent += `<li class="border-2 border-violet-50 text-lg font-light text-slate-900 p-2 rounded-lg">${language}</li>`;
                });

                htmlContent += `</ul>
                </section>`;

                // Inject the generated HTML into the resumeContainer
                document.getElementById('resumeContainer').innerHTML = htmlContent;

            } catch (error) {
                console.error('Error fetching the JSON data:', error);
            }
        }

        // Call the function to display the resume
        displayResume();
    

       
            